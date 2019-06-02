require 'rails_helper'


RSpec.describe "adding an item to the cart" do
  before :each do
    @item = create(:item)
  end

  context "a visitor or regular user can add items to the cart" do
    before :each do
      @user = create(:user)
      create(:address, user: @user)
    end

    scenario "as a visitor" do
      visit item_path(@item)
    end

    scenario "as a regular user" do
      login_as(@user)
      visit item_path(@item)
    end

    after :each do
      visit item_path(@item)
      expect(page).to have_content("Cart: 0")
      click_on "Add to Cart"
      expect(page).to have_content("#{@item.name} has been added to your cart!")
      expect(page).to have_content("Cart: 1")
      visit item_path(@item)
      click_on "Add to Cart"
      expect(page).to have_content("#{@item.name} has been added to your cart!")
      expect(page).to have_content("Cart: 2")
    end
  end

  context "an admin or merchant does not see add cart button" do
    before :each do
      @merchant = create(:merchant)
      create(:address, user: @merchant)
      @admin = create(:admin)
    end

    scenario "as an admin" do
      login_as(@admin)
    end

    scenario "as a merchant" do
      login_as(@merchant)
    end

    after :each do
      visit item_path(@item)

      expect(page).to_not have_link("Add to Cart")
    end
  end
end
