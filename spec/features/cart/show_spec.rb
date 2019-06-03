require 'rails_helper'

RSpec.describe "Cart show page" do
  before :each do
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)
    @item_1 = create(:item, user: @merchant_1, inventory: 3)
    @item_2 = create(:item, user: @merchant_2)
    @item_3 = create(:item, user: @merchant_2)
  end

  context "a regular user or visitor sees their cart summary" do
    scenario "as a regular user" do
      user = create(:user)
        a1 = create(:address, user: user)
      login_as(user)
    end

    scenario "as a visitor" do
    end

    after :each do
      visit item_path(@item_1)
      click_on "Add to Cart"
      visit item_path(@item_2)
      click_on "Add to Cart"
      visit item_path(@item_3)
      click_on "Add to Cart"
      visit item_path(@item_3)
      click_on "Add to Cart"

      visit cart_path

      expect(page).to have_content("Total: $#{@item_1.price + @item_2.price + @item_3.price * 2}")

      expect(page).to have_button("Empty Cart")

      within("#item-#{@item_1.id}") do
        expect(page).to have_content(@item_1.name)
        expect(page).to have_xpath("//img[@src='#{@item_1.image}']")
        expect(page).to have_content(@item_1.user.name)
        expect(page).to have_content(@item_1.price)
        expect(page).to have_content("quantity: 1")
        expect(page).to have_content("subtotal: $#{@item_1.price}")
      end

      within("#item-#{@item_2.id}") do
        expect(page).to have_content(@item_2.name)
        expect(page).to have_xpath("//img[@src='#{@item_2.image}']")
        expect(page).to have_content(@item_2.user.name)
        expect(page).to have_content(@item_2.price)
        expect(page).to have_content("quantity: 1")
        expect(page).to have_content("subtotal: $#{@item_2.price}")
      end

      within("#item-#{@item_3.id}") do
        expect(page).to have_content(@item_3.name)
        expect(page).to have_xpath("//img[@src='#{@item_3.image}']")
        expect(page).to have_content(@item_3.user.name)
        expect(page).to have_content(@item_3.price)
        expect(page).to have_content("quantity: 2")
        expect(page).to have_content("subtotal: $#{@item_3.price * 2}")
      end
    end
  end

  context "a regular user or visitor sees an empty cart message" do
    scenario "as a regular user" do
      user = create(:user)
        a1 = create(:address, user: user)
      login_as(user)
    end

    scenario "as a visitor" do
    end

    after :each do
      visit cart_path

      expect(page).to have_content("Your Cart is empty.")
      expect(page).to_not have_button("Empty Cart")
    end
  end

  context "a regular user or visitor can empty their cart" do
    scenario "as a regular user" do
      user = create(:user)
      a1 = create(:address, user: user)
      login_as(user)
    end

    scenario "as a visitor" do
    end

    after :each do
      visit item_path(@item_1)
      click_on "Add to Cart"
      visit item_path(@item_2)
      click_on "Add to Cart"
      visit item_path(@item_3)
      click_on "Add to Cart"
      visit item_path(@item_3)
      click_on "Add to Cart"

      visit cart_path
      click_on "Empty Cart"

      expect(current_path).to eq(cart_path)
      expect(page).to have_content("Cart: 0")
      expect(page).to have_content("Your Cart is empty.")
    end
  end

  context "a regular user or visitor can remove an item from the cart" do
    scenario "as a regular user" do
      user = create(:user)
      a1 = create(:address, user: user)
      login_as(user)
    end

    scenario "as a visitor" do
    end

    after :each do
      visit item_path(@item_1)
      click_on "Add to Cart"
      visit item_path(@item_3)
      click_on "Add to Cart"
      visit item_path(@item_3)
      click_on "Add to Cart"

      visit cart_path

      within("#item-#{@item_3.id}") do
        click_button("delete")
      end

      expect(page).to_not have_css("#item-#{@item_3.id}")
      expect(page).to have_css("#item-#{@item_1.id}")
      expect(page).to have_content("#{@item_3.name} has been removed from your cart.")
    end
  end

  context "a regular user or visitor can increment item quantities" do
    scenario "as a regular user" do
      user = create(:user)
      a1 = create(:address, user: user)
      login_as(user)
    end

    scenario "as a visitor" do
    end

    after :each do
      visit item_path(@item_1)
      click_on "Add to Cart"

      visit cart_path

      expect(page).to have_content("quantity: 1")
      click_button("+")
      expect(page).to have_content("#{@item_1.name} has been added to your cart!")
      expect(page).to have_content("quantity: 2")
      click_button("+")
      expect(page).to have_content("#{@item_1.name} has been added to your cart!")
      expect(page).to have_content("quantity: 3")
      click_button("+")
      expect(page).to have_content("The Merchant does not have enough inventory.")
      expect(page).to have_content("quantity: 3")
    end
  end

  context "a regular user or visitor can decrement item quantities" do
    scenario "as a regular user" do
      user = create(:user)
      a1 = create(:address, user: user)
      login_as(user)
    end

    scenario "as a visitor" do
    end

    after :each do
      visit item_path(@item_3)
      click_on "Add to Cart"
      visit item_path(@item_3)
      click_on "Add to Cart"

      visit cart_path

      expect(page).to have_content("quantity: 2")
      click_button("-")
      expect(page).to have_content("#{@item_3.name} has been removed from your cart.")
      expect(page).to have_content("quantity: 1")
      click_button("-")

      expect(page).to_not have_css("#item-#{@item_3.id}")
    end
  end
end
