require 'rails_helper'

RSpec.describe "clicking the logout button" do
  before :each do
    @user = create(:user)
    create(:address, user: @user)
    login_as(@user)
    visit root_path
    click_link "Log out"
  end

  it "logs out the user" do
    expect(current_path).to eq(root_path)
    expect(page).to have_content("You have successfully logged out.")
    expect(page).to have_content("Log in")
    expect(page).to_not have_content("Log Out")
  end

  it "deletes all items in the cart" do
    item = create(:item)

    visit item_path(item)
    click_on "Add to Cart"
    visit item_path(item)
    click_on "Add to Cart"
    expect(page).to have_content("Cart: 2")

    visit logout_path

    expect(page).to have_content("Cart: 0")

    visit cart_path
    expect(page).to have_content("Your Cart is empty.")
  end
end
