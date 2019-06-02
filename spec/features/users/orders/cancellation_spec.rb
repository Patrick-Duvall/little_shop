require 'rails_helper'

RSpec.describe 'User Order workflow', type: :feature do
  before :each do
    @user = create(:user)
    @admin = create(:admin)

    @merchant_1 = create(:merchant)
    @merchant_2 = create(:merchant)

    @inventory_level = 20
    @purchased_amount = 5
    @item_1 = create(:item, user: @merchant_1)
    @item_2 = create(:item, user: @merchant_2, inventory: @inventory_level)

    @order_1 = create(:order, user: @user, created_at: 1.day.ago)
    @oi_1 = create(:order_item, order: @order_1, item: @item_1, price: 1, quantity: 1, created_at: 1.day.ago)
    @oi_2 = create(:fulfilled_order_item, order: @order_1, item: @item_2, price: 2, quantity: @purchased_amount, created_at: 1.day.ago, updated_at: 2.hours.ago)

    @order_2 = create(:packaged_order, user: @user, created_at: 1.day.ago)
    @oi_1 = create(:order_item, order: @order_2, item: @item_1, price: 1, quantity: 1, created_at: 1.day.ago)
    @oi_2 = create(:fulfilled_order_item, order: @order_2, item: @item_2, price: 2, quantity: @purchased_amount, created_at: 1.day.ago, updated_at: 2.hours.ago)

    @order_3 = create(:shipped_order, user: @user, created_at: 1.day.ago)
    @oi_1 = create(:fulfilled_order_item, order: @order_3, item: @item_1, price: 1, quantity: 1, created_at: 1.day.ago, updated_at: 5.hours.ago)
    @oi_2 = create(:fulfilled_order_item, order: @order_3, item: @item_2, price: 2, quantity: 1, created_at: 1.day.ago, updated_at: 2.hours.ago)

    visit item_path(@item_2)
    expect(page).to have_content("In stock: #{@inventory_level}")
  end

  describe 'as a user trying to cancel someone elses order' do
    it 'should not be successful' do
      @user2 = create(:user)
      login_as(@user2)
      page.driver.submit :delete, "/profile/orders/#{@order_1.id}", {}
      expect(page.status_code).to eq(404)
    end
  end

  describe 'order cancellation' do
    scenario 'as a user' do
      login_as(@user)

      visit profile_order_path(@order_1)
      expect(page).to have_button('Cancel Order')

      visit profile_order_path(@order_2)
      expect(page).to have_button('Cancel Order')

      visit profile_order_path(@order_3)
      expect(page).to_not have_button('Cancel Order')

      @am_user = true
    end

    # do same but as an admin

    after :each do
      visit profile_order_path(@order_1)
      click_button('Cancel Order')

      expect(current_path).to eq(profile_orders_path)

      within "#order-#{@order_1.id}" do
        expect(page).to have_content("Status: cancelled")
      end

      click_link "Order ID #{@order_1.id}"

      @order_1.order_items.each do |oi|
        within "#oitem-#{oi.id}" do
          expect(page).to have_content("Fulfilled: No")
        end
      end

      visit item_path(@item_2)
      expect(page).to have_content("In stock: #{@inventory_level + @purchased_amount}")

      # cancel order 2
      visit profile_order_path(@order_2)
      click_button('Cancel Order')

      expect(current_path).to eq(profile_orders_path)

      within "#order-#{@order_2.id}" do
        expect(page).to have_content("Status: cancelled")
      end

      click_link "Order ID #{@order_2.id}"

      @order_2.order_items.each do |oi|
        within "#oitem-#{oi.id}" do
          expect(page).to have_content("Fulfilled: No")
        end
      end

      visit item_path(@item_2)
      expect(page).to have_content("In stock: #{@inventory_level + @purchased_amount + @purchased_amount}")
    end
  end
end
