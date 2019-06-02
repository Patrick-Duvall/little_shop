require 'rails_helper'

RSpec.describe 'Admin User Index' do
  describe 'as an admin' do
    it 'sees all default users with links to admin user path' do
      @user_1 = create(:user)
      create(:address, user: @user_1)
      @user_2 = create(:user)
      create(:address, user: @user_2)
      @merchant = create(:merchant)
      @admin_1 = create(:admin)
      @admin_2 = create(:admin)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin_1)

      visit admin_users_path

      within("#user-#{@user_1.id}") do
        expect(page).to have_link(@user_1.name)
        expect(page).to have_content("Registered On: #{@user_1.created_at.to_time.strftime('%B %e, %Y')}")
        expect(page).to have_button("Upgrade to Merchant")
      end

      within("#user-#{@user_2.id}") do
        expect(page).to have_link(@user_2.name)
        expect(page).to have_content("Registered On: #{@user_2.created_at.to_time.strftime('%B %e, %Y')}")
        expect(page).to have_button("Upgrade to Merchant")
      end

      expect(page).to_not have_css("#user-#{@merchant.id}")
      expect(page).to_not have_css("#user-#{@admin_1.id}")
      expect(page).to_not have_css("#user-#{@admin_2.id}")

      click_link @user_1.name

      expect(current_path).to eq(admin_user_path(@user_1))
    end
  end
end
