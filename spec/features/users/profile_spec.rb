require 'rails_helper'

RSpec.describe 'user profile', type: :feature do
  before :each do
    @user = create(:user)
    @address = create(:address, user: @user)
  end

  describe 'registered user visits their profile' do
    it 'shows user information' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_path

      within '#profile-data' do
        expect(page).to have_content("Role: #{@user.role}")
        expect(page).to have_content("Email: #{@user.email}")
        within '#address-details' do
          expect(page).to have_content("Address: #{@user.addresses.first.address}")
          expect(page).to have_content("#{@user.addresses.first.city}, #{@user.addresses.first.state} #{@user.addresses.first.zip}")
        end
        expect(page).to have_link('Edit Profile Data')
      end
    end
  end

  describe 'registered user edits their profile' do
    describe 'edit user form' do
      it 'pre-fills form with all but password information' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

        visit profile_path
        click_link 'Edit Profile Data'

        expect(current_path).to eq('/profile/edit')
        expect(find_field('Name').value).to eq(@user.name)
        expect(find_field('Email').value).to eq(@user.email)
        expect(find_field('Password').value).to eq(nil)
        expect(find_field('Password confirmation').value).to eq(nil)
      end
    end

    describe 'user information is updated' do
      before :each do
        @updated_name = 'Updated Name'
        @updated_email = 'updated_email@example.com'
        @updated_password = 'newandextrasecure'
      end

      describe 'succeeds with allowable updates' do
        scenario 'all attributes are updated' do
          login_as(@user)
          old_digest = @user.password_digest

          visit edit_profile_path

          fill_in :user_name, with: @updated_name
          fill_in :user_email, with: @updated_email
          fill_in :user_password, with: @updated_password
          fill_in :user_password_confirmation, with: @updated_password

          click_button 'Submit'

          updated_user = User.find(@user.id)

          expect(current_path).to eq(profile_path)
          expect(page).to have_content("Your profile has been updated")
          expect(page).to have_content("#{@updated_name}")
          within '#profile-data' do
            expect(page).to have_content("Email: #{@updated_email}")
            within '#address-details' do
            end
          end
          expect(updated_user.password_digest).to_not eq(old_digest)
        end
        scenario 'works if no password is given' do
          login_as(@user)
          old_digest = @user.password_digest

          visit edit_profile_path

          fill_in :user_name, with: @updated_name
          fill_in :user_email, with: @updated_email

          click_button 'Submit'

          updated_user = User.find(@user.id)

          expect(current_path).to eq(profile_path)
          expect(page).to have_content("Your profile has been updated")
          expect(page).to have_content("#{@updated_name}")
          within '#profile-data' do
            expect(page).to have_content("Email: #{@updated_email}")
          end
          expect(updated_user.password_digest).to eq(old_digest)
        end
      end
    end

    it 'fails with non-unique email address change' do
      create(:user, email: 'megan@example.com')
      login_as(@user)

      visit edit_profile_path

      fill_in :user_email, with: 'megan@example.com'

      click_button 'Submit'

      expect(page).to have_content("Email has already been taken")
    end
  end

  describe "User can manage addresses" do
    before :each do
      @u1 = create(:user)
      create(:address, user: @u1)
      visit root_path
      click_link "Log in"
      fill_in "email", with: @u1.email
      fill_in "password", with: @u1.password
      click_button "Log in"
    end


    it "allows me to add an address" do

      click_link "Add address"
      expect(current_path).to eq(new_user_address_path(@u1))
      fill_in "address_nick_name", with: "work"
      fill_in "address_address", with: "123 st"
      fill_in "address_city", with: "Granger"
      fill_in "address_state", with: "Montana"
      fill_in "address_zip", with: "12544"

      click_button "Create Address"

      expect(current_path).to eq(profile_path)
      within "#address-#{Address.last.id}" do
      expect(page).to have_content("work : 123 st, Granger Montana, 12544")
    end
    end

    it "allows me to delete an address" do
      a1 = @u1.addresses.create(nick_name: "work", address: "223 road", city: "town", state: "Indiana", zip: "47906")
      a2 = @u1.addresses.create(nick_name: "school", address: "2243 lane", city: "ville", state: "Maine", zip: "47906")
      visit profile_path
      within "#address-#{a1.id}" do
        click_link "Delete #{a1.nick_name}"
      end
      expect(current_path).to eq(profile_path)
      expect(page).to_not have_content("#{a1.nick_name} : #{a1.address}, #{a1.city} #{a1.state}, #{a1.zip}")

      within "#address-#{a2.id}" do
        click_link "Delete #{a2.nick_name}"
      end
      expect(page).to_not have_content("#{a2.nick_name} : #{a2.address}, #{a2.city} #{a2.state}, #{a2.zip}")
    end

    it "lets me delete an address with orders, sets orders address id to nil" do
      a1 = create(:address, user: @u1)
      order = create(:order, user: @u1, address: a1)
      visit profile_path
      within "#address-#{a1.id}" do
        click_link "Delete #{a1.nick_name}"
      end
      expect(current_path).to eq(profile_path)
      expect(page).to_not have_css("#address-#{a1.id}")
      order.reload
      expect(order.address_id).to eq(nil)
      click_link("Customer Orders")
      within "#order-#{order.id}" do
        expect(page).to have_content("Order ID #{order.id}")
        expect(page).to_not have_content("Address: #{a1.nick_name}")
      end

    end

#     As a registered user, When I visit my profile
# -Next to each address I see a button to edit that address.
# -When I click this button I am taken to an address edit form
# -When I fill out and submit this form I am redirected to my profile
# -where the address is edited

    it "allows me to update an address" do
      a1 = @u1.addresses.create(nick_name: "work", address: "223 road", city: "town", state: "Indiana", zip: "47906")
      a2 = @u1.addresses.create(nick_name: "school", address: "2243 lane", city: "ville", state: "Maine", zip: "47906")
      visit profile_path
      within "#address-#{a1.id}" do
        click_link "Edit #{a1.nick_name}"
      end
    fill_in "address_address", with: "444 blvd"
    fill_in "address_city", with: "Dead Horse"
    fill_in "address_state", with: "Montana"
    fill_in "address_zip", with: "12544"
    click_button "Update Address"
    expect(current_path).to eq(profile_path)
    expect(page).to have_content("work : 444 blvd, Dead Horse Montana, 12544")
      within "#address-#{a1.id}" do
        click_link "Edit #{a1.nick_name}"
      end
    fill_in "address_zip", with: "80543"
    click_button "Update Address"
    expect(page).to have_content("work : 444 blvd, Dead Horse Montana, 80543")

    end

    it "still loads my profile page when I have no addresses" do
      user = create(:user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit profile_path
        expect(page).to_not have_content('Primary Address:')
      expect(page).to_not have_content('My Addresses')
    end

    it "still shows user addresses when they exist" do
      user = create(:user)
      address = create(:address, user: user)
      address2 = create(:address, user: user)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      visit profile_path
      within "#address-details" do
        expect(page).to have_content(user.addresses.first.address)
      end
      within "#address-#{address.id}" do
        expect(page).to have_link("Delete #{address.nick_name}")
      end
      within "#address-#{address2.id}" do
        expect(page).to have_link("Delete #{address2.nick_name}")
      end
    end

#     As a registered user, when I visit my profile_orders
# -if an order is pending
# -next to each order I see a dropdown of my addresses
# If I change my address on this dropdown and click submit
# -I am redirected to my profile page
# -And see the address for this order has changed.
# -If I try to visit the path to change a non pending order I am redirected to a 404

    describe "when I have a pending order" do
      it "lets me edit the address of that order" do
        click_link "Log out"
        user = create(:user)
        address = create(:address, user:user)
        address2 = create(:address, user:user, nick_name: 'school' )
        address3 = create(:address, user:user, nick_name: 'work' )
        address4 = create(:address, user:user, nick_name: 'other' )

        pending_order = create(:order, user: user, address: address)
        pending_order2 = create(:order, user: user, address: address4)
        packaged_order = create(:packaged_order, user: user, address: address)
        shipped_order = create(:shipped_order, user: user, address: address)
        cancelled_order = create(:cancelled_order, user: user, address: address)
        login_as(user)
        visit profile_orders_path
        within "#order-#{pending_order.id}" do
          expect(page).to have_link("Change Address to #{address2.nick_name}")
          expect(page).to have_link("Change Address to #{address3.nick_name}")
          expect(page).to_not have_link("Change Address to #{address.nick_name}")
        end
        within "#order-#{packaged_order.id}" do
          expect(page).to_not have_link("Change Address to #{address2.nick_name}")
          expect(page).to_not have_link("Change Address to #{address3.nick_name}")
        end
        within "#order-#{shipped_order.id}" do
          expect(page).to_not have_link("Change Address to #{address2.nick_name}")
          expect(page).to_not have_link("Change Address to #{address3.nick_name}")
        end
        within "#order-#{cancelled_order.id}" do
          expect(page).to_not have_link("Change Address to #{address2.nick_name}")
          expect(page).to_not have_link("Change Address to #{address3.nick_name}")
        end

        within "#order-#{pending_order.id}" do
          click_link("Change Address to #{address2.nick_name}")
        end
        expect(current_path).to eq(profile_orders_path)
        within "#order-#{pending_order.id}" do
          expect(page).to have_content("Address: #{address2.nick_name}")
        end
        within "#order-#{pending_order2.id}" do
          click_link("Change Address to #{address3.nick_name}")
        end
        within "#order-#{pending_order2.id}" do
          expect(page).to have_content("Address: #{address3.nick_name}")
        end
      end
    end

    describe "addresses with associated orders cant be changed" do
      it "does not allow me to delete an address associated with a packaged/shipped order" do
        click_link("Log out")
        user = create(:user)
        address = create(:address, user:user)
        address2 = create(:address, user:user, nick_name: 'school' )
        address3 = create(:address, user:user, nick_name: 'work' )
        address4 = create(:address, user:user, nick_name: 'other' )

        pending_order = create(:order, user: user, address: address)
        pending_order2 = create(:order, user: user, address: address4)
        packaged_order = create(:packaged_order, user: user, address: address3)
        shipped_order = create(:shipped_order, user: user, address: address2)
        cancelled_order = create(:cancelled_order, user: user, address: address4)
        login_as(user)
        visit profile_path
        within "#address-#{address4.id}" do #cancelled can change
          click_link("Delete #{address4.nick_name}")
        end
        expect(current_path).to eq(profile_path)
        expect(page).to_not have_css("#address-#{address4.nick_name}")
        within "#address-#{address3.id}" do #packaged cannot
          click_link("Delete #{address3.nick_name}")
        end
        expect(current_path).to eq(profile_path)
        expect(page).to have_content("Cannot Delete #{address3.nick_name}, it is associated with a packaged or shipped order")
        expect(page).to have_css("#address-#{address3.id}")
        within "#address-#{address2.id}" do #shipped canot
          click_link("Delete #{address2.nick_name}")
        end
        expect(page).to have_content("Cannot Delete #{address2.nick_name}, it is associated with a packaged or shipped order")
        expect(page).to have_css("#address-#{address2.id}")
        within "#address-#{address.id}" do #pending can
          click_link("Delete #{address.nick_name}")
        end
        expect(page).to_not have_content("Cannot Delete #{address.nick_name}, it is associated with a packaged or shipped order")
        expect(page).to_not have_css("#address-#{address.id}")
      end
      it "does not allow me to delete an address associated with a packaged/shipped order" do
        click_link("Log out")
        user = create(:user)
        address = create(:address, user:user)
        address2 = create(:address, user:user, nick_name: 'school' )
        address3 = create(:address, user:user, nick_name: 'work' )
        address4 = create(:address, user:user, nick_name: 'other' )

        pending_order = create(:order, user: user, address: address)
        pending_order2 = create(:order, user: user, address: address4)
        packaged_order = create(:packaged_order, user: user, address: address3)
        shipped_order = create(:shipped_order, user: user, address: address2)
        cancelled_order = create(:cancelled_order, user: user, address: address4)
        login_as(user)
        visit profile_path
        within "#address-#{address4.id}" do #cancelled can change
          click_link("Edit #{address4.nick_name}")
        end
        fill_in "address_nick_name", with: "a new address"
        click_button "Update Address"
        expect(current_path).to eq(profile_path)
        within("#address-#{address4.id}") do
          expect(page).to have_content("a new address")
        end
        within "#address-#{address3.id}" do #packaged cannot
          click_link("Edit #{address3.nick_name}")
        end
        expect(current_path).to eq(profile_path)
        expect(page).to have_content("Cannot Edit #{address3.nick_name}, it is associated with a packaged or shipped order")
        expect(page).to have_css("#address-#{address3.id}")
        within "#address-#{address2.id}" do #shipped canot
          click_link("Edit #{address2.nick_name}")
        end
        expect(page).to have_content("Cannot Edit #{address2.nick_name}, it is associated with a packaged or shipped order")
        expect(page).to have_css("#address-#{address2.id}")
        within "#address-#{address.id}" do #pending can
          click_link("Edit #{address.nick_name}")
        end
        fill_in "address_state", with: "Mississippi"
        click_button "Update Address"
        expect(page).to_not have_content("Cannot Edit #{address.nick_name}, it is associated with a packaged or shipped order")
        within ("#address-#{address.id}") do
          expect(page).to have_content("Mississippi")
        end

      end
    end

  end
end
