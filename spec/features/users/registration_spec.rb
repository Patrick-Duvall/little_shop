require 'rails_helper'

RSpec.describe 'the registration page' do
  describe 'happy path' do
    it "should create a new user after filling out the form" do
      visit registration_path
      fill_in :user_name, with: "name"
      fill_in "Address", with: "address"
      fill_in "City", with: "city"
      fill_in "State", with: "state"
      fill_in "Zip", with: "zip"
      fill_in :user_email, with: "example@gmail.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "password"

      click_button "Submit"

      expect(current_path).to eq(profile_path)
      within "#address-#{Address.last.id}" do
        expect(page).to have_content("home : address, city state, zip")
      end

      user = User.last

      expect(page).to have_content("Registration Successful! You are now logged in.")
      expect(page).to have_content("Logged in as #{user.name}")
      
    end
  end

  describe 'sad path' do
    it "should display error messages for each unfilled field" do
      visit registration_path

      click_button "Submit"

      expect(current_path).to eq(registration_path)

      expect(page).to have_content("Password can't be blank")
      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Address can't be blank")
      expect(page).to have_content("City can't be blank")
      expect(page).to have_content("State can't be blank")
      expect(page).to have_content("Zip can't be blank")
      expect(page).to have_content("Email can't be blank")
    end

    it "should display an error when an email is taken" do
      user = create(:user)
      user.update(email: "example@gmail.com")

      visit registration_path

      fill_in :user_name, with: "name_1"
      fill_in :user_address, with: "address_1"
      fill_in :user_city, with: "city_1"
      fill_in :user_state, with: "state_1"
      fill_in :user_zip, with: "zip_1"
      fill_in :user_email, with: "example@gmail.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "password"

      click_button "Submit"

      expect(current_path).to eq(registration_path)
      expect(page).to have_content("Email has already been taken")

      expect(page).to have_css("input[value='name_1']")
      expect(page).to have_css("input[value='address_1']")
      expect(page).to have_css("input[value='city_1']")
      expect(page).to have_css("input[value='state_1']")
      expect(page).to have_css("input[value='zip_1']")
      expect(page).to_not have_css("input[value='example@gmail.com']")
      expect(page).to_not have_css("input[value='password']")
    end

    it "should display an error when password confirmation doesn't match" do
      visit registration_path

      fill_in :user_name, with: "name"
      fill_in :user_address, with: "address"
      fill_in :user_city, with: "city"
      fill_in :user_state, with: "state"
      fill_in :user_zip, with: "zip"
      fill_in :user_email, with: "example@gmail.com"
      fill_in :user_password, with: "password"
      fill_in :user_password_confirmation, with: "a different password"

      click_button "Submit"

      expect(current_path).to eq(registration_path)
      expect(page).to have_content("Password confirmation doesn't match Password")
    end
  end
end
