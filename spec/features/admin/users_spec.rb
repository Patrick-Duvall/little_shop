require 'rails_helper'

RSpec.describe "admin users workflow" do
  before :each do
    @admin = create(:admin)
    @user = create(:user)
    create(:address, user: @user)
  end

  context "as an admin" do
    it "can upgrade a user to a merchant" do
      login_as(@admin)
      visit admin_user_path(@user)

      click_button "Upgrade User to Merchant"

      expect(current_path).to eq(admin_merchant_path(@user))
      expect(page).to have_content("#{@user.name} is now a merchant.")

      click_link "Log out"
      login_as(@user)
      visit dashboard_path
      expect(page).to have_content("Merchant Dashboard")
    end
  end

  context "as a non admin" do
    it "cannot reach the page" do
      login_as(@user)
      visit admin_user_path(@user)
      expect(page).to have_content("The page you were looking for doesn't exist.")
    end
  end
end
