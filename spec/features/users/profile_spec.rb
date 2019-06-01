require 'rails_helper'

RSpec.describe 'user profile', type: :feature do
  before :each do
    @user = create(:user)
  end

  describe 'registered user visits their profile' do
    it 'shows user information' do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

      visit profile_path

      within '#profile-data' do
        expect(page).to have_content("Role: #{@user.role}")
        expect(page).to have_content("Email: #{@user.email}")
        within '#address-details' do
          expect(page).to have_content("Address: #{@user.address}")
          expect(page).to have_content("#{@user.city}, #{@user.state} #{@user.zip}")
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

        click_link 'Edit'

        expect(current_path).to eq('/profile/edit')
        expect(find_field('Name').value).to eq(@user.name)
        expect(find_field('Email').value).to eq(@user.email)
        expect(find_field('Address').value).to eq(@user.address)
        expect(find_field('City').value).to eq(@user.city)
        expect(find_field('State').value).to eq(@user.state)
        expect(find_field('Zip').value).to eq(@user.zip)
        expect(find_field('Password').value).to eq(nil)
        expect(find_field('Password confirmation').value).to eq(nil)
      end
    end

    describe 'user information is updated' do
      before :each do
        @updated_name = 'Updated Name'
        @updated_email = 'updated_email@example.com'
        @updated_address = 'newest address'
        @updated_city = 'new new york'
        @updated_state = 'S. California'
        @updated_zip = '33333'
        @updated_password = 'newandextrasecure'
      end

      describe 'succeeds with allowable updates' do
        scenario 'all attributes are updated' do
          login_as(@user)
          old_digest = @user.password_digest

          visit edit_profile_path

          fill_in :user_name, with: @updated_name
          fill_in :user_email, with: @updated_email
          fill_in :user_address, with: @updated_address
          fill_in :user_city, with: @updated_city
          fill_in :user_state, with: @updated_state
          fill_in :user_zip, with: @updated_zip
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
              expect(page).to have_content("#{@updated_address}")
              expect(page).to have_content("#{@updated_city}, #{@updated_state} #{@updated_zip}")
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
          fill_in :user_address, with: @updated_address
          fill_in :user_city, with: @updated_city
          fill_in :user_state, with: @updated_state
          fill_in :user_zip, with: @updated_zip

          click_button 'Submit'

          updated_user = User.find(@user.id)

          expect(current_path).to eq(profile_path)
          expect(page).to have_content("Your profile has been updated")
          expect(page).to have_content("#{@updated_name}")
          within '#profile-data' do
            expect(page).to have_content("Email: #{@updated_email}")
            within '#address-details' do
              expect(page).to have_content("#{@updated_address}")
              expect(page).to have_content("#{@updated_city}, #{@updated_state} #{@updated_zip}")
            end
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
    within "#address-#{a12.id}" do
      click_button "Delete #{a12.nick_name}"
    end
      expect(page).to_not have_content("#{a2.nick_name} : #{a2.address}, #{a2.city} #{a2.state}, #{a2.zip}")
    end

  end
end
