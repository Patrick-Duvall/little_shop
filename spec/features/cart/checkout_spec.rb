require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe "Checking out" do
  before :each do
    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)
    @item_1 = create(:item, user: @merchant_1, inventory: 3)
    @item_2 = create(:item, user: @merchant_2)
    @item_3 = create(:item, user: @merchant_2)

    visit item_path(@item_1)
    click_on "Add to Cart"
    visit item_path(@item_2)
    click_on "Add to Cart"
    visit item_path(@item_3)
    click_on "Add to Cart"
    visit item_path(@item_3)
    click_on "Add to Cart"
  end

  context "as a logged in regular user" do
    before :each do
      user = create(:user)
      a1 = create(:address, user: user)
      login_as(user)
      visit cart_path

      click_button "Check Out"
      @new_order = Order.last
    end

    it "should create a new order" do
      expect(current_path).to eq(profile_orders_path)
      expect(page).to have_content("Your order has been created!")
      expect(page).to have_content("Cart: 0")
      within("#order-#{@new_order.id}") do
        expect(page).to have_link("Order ID #{@new_order.id}")
        expect(page).to have_content("Status: pending")
      end
    end

    it "should create order items" do
      visit profile_order_path(@new_order)

      within("#oitem-#{@new_order.order_items.first.id}") do
        expect(page).to have_content(@item_1.name)
        expect(page).to have_content(@item_1.description)
        expect(page.find("#item-#{@item_1.id}-image")['src']).to have_content(@item_1.image)
        expect(page).to have_content("Merchant: #{@merchant_1.name}")
        expect(page).to have_content("Price: #{number_to_currency(@item_1.price)}")
        expect(page).to have_content("Quantity: 1")
        expect(page).to have_content("Fulfilled: No")
      end

      within("#oitem-#{@new_order.order_items.second.id}") do
        expect(page).to have_content(@item_2.name)
        expect(page).to have_content(@item_2.description)
        expect(page.find("#item-#{@item_2.id}-image")['src']).to have_content(@item_2.image)
        expect(page).to have_content("Merchant: #{@merchant_2.name}")
        expect(page).to have_content("Price: #{number_to_currency(@item_2.price)}")
        expect(page).to have_content("Quantity: 1")
        expect(page).to have_content("Fulfilled: No")
      end

      within("#oitem-#{@new_order.order_items.third.id}") do
        expect(page).to have_content(@item_3.name)
        expect(page).to have_content(@item_3.description)
        expect(page.find("#item-#{@item_3.id}-image")['src']).to have_content(@item_3.image)
        expect(page).to have_content("Merchant: #{@merchant_2.name}")
        expect(page).to have_content("Price: #{number_to_currency(@item_3.price)}")
        expect(page).to have_content("Quantity: 2")
        expect(page).to have_content("Fulfilled: No")
      end
    end
  end

  describe "when checking out" do
    it "allows me to choose an address to ship to" do
      user = create(:user)
      a1 = create(:address, user: user)
      login_as(user)
      visit cart_path

      click_button "Check Out #{user.addresses[0].nick_name}"
      new_order = Order.last
      expect(current_path).to eq(profile_orders_path)
      within("#order-#{new_order.id}") do
        expect(page).to have_link("Order ID #{new_order.id}")
        expect(page).to have_content("Status: pending")
        expect(page).to have_content("Address: #{user.addresses[0].nick_name}")
      end

      it "shows multiple checkout options If I have multiple addresses" do
        user = create(:user)
        a1 = create(:address, user: user)
        a2 = create(:address, user: user, nick_name: school)
        a3 = create(:address, user: user, nick_name: work)
        login_as(user)
        visit cart_path

        expect(page).to have_button("Check Out #{user.addresses[0].nick_name}")
        expect(page).to have_button("Check Out #{user.addresses[1].nick_name}")
        expect(page).to have_button("Check Out #{user.addresses[2].nick_name}")
        click_button "Check Out #{user.addresses[2].nick_name}"
        new_order = Order.last
        within("#order-#{new_order.id}") do
          expect(page).to have_link("Order ID #{new_order.id}")
          expect(page).to have_content("Status: pending")
          expect(page).to have_content("Address: #{user.addresses[2].nick_name}")
        end

      end
    end
    it "does not let me checkout with no addresses" do
        user = create(:user)
        login_as(user)
        visit cart_path
        expect(page).to have_link("You must have an address to check out")
        expect(page).to_not have_button("Check Out")
        click_link("You must have an address to check out")
        expect(current_path).to eq(new_user_address_path(user))
    end
    it "doesnt tell me I need an address If I have one" do
      user = create(:user)
      a1 = create(:address, user: user)
      login_as(user)
      visit cart_path
      expect(page).to_not have_link("You must have an address to check out")
    end
    # it "renders 404 if I try manually" do
    #   # -If I try to check out manually I am redirected to a 404 page
    #   user = create(:user)
    #   visit profile_order_path(user)
    #   expect(page.status_code).to eq(404)
    #
    # end
  end

  context "as a visitor" do
    it "should tell the user to login or register" do
      visit cart_path

      expect(page).to have_content("You must register or log in to check out.")
      click_link "register"
      expect(current_path).to eq(registration_path)

      visit cart_path

      click_link "log in"
      expect(current_path).to eq(login_path)
    end


  end
end
