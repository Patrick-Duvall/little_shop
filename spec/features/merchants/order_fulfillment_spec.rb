require 'rails_helper'

include ActionView::Helpers::NumberHelper

RSpec.describe 'merchant order show workflow' do
  describe 'as a merchant' do
    before :each do
      @merchant1 = create(:merchant)
      create(:address, user: @merchant1)
      @merchant2 = create(:merchant)
      create(:address, user: @merchant2)
      @user = create(:user)
      a1 = create(:address, user: @user)
      @order = create(:order, user: @user, address: a1)
      @item1 = create(:item, user: @merchant1, inventory: 2)
      @item2 = create(:item, user: @merchant2, inventory: 2)
      @item3 = create(:item, user: @merchant1, inventory: 2)
      @oi1 = create(:order_item, order: @order, item: @item1, quantity: 1, price: 2)
      @oi2 = create(:order_item, order: @order, item: @item2, quantity: 2, price: 3)
      @oi3 = create(:order_item, order: @order, item: @item3, quantity: 3, price: 4)

      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant1)
    end

    describe 'visit dashboard order page' do
      it 'dashboard links to order show page' do
        visit dashboard_path

        click_link("#{@order.id}")

        expect(current_path).to eq(dashboard_order_path(@order))
      end

      it 'shows user information for order' do
        visit dashboard_order_path(@order)

        expect(page).to have_content("Customer Name: #{@user.name}")
        expect(page).to have_content("Customer Address: #{@user.addresses.first.address} #{@user.addresses.first.city}, #{@user.addresses.first.state} #{@user.addresses.first.zip}")
      end

      it 'shows item information for that merchant' do
        visit dashboard_order_path(@order)

        within "#oitem-#{@oi1.id}" do
          expect(page).to have_link(@oi1.item.name)
          expect(page.find("#item-#{@oi1.item.id}-image")['src']).to have_content(@oi1.item.image)
          expect(page).to have_content("Price: #{number_to_currency(@oi1.price)}")
          expect(page).to have_content("Quantity: #{@oi1.quantity}")
          expect(page).to have_content("Subtotal: #{number_to_currency(@oi1.price*@oi1.quantity)}")
          expect(page).to have_content("Fulfilled: No")
        end
      end

      it "only shows information for merchant's items" do
        visit dashboard_order_path(@order)

        expect(page).to have_css("#oitem-#{@oi1.id}")
        expect(page).to have_css("#oitem-#{@oi3.id}")
        expect(page).to_not have_css("#oitem-#{@oi2.id}")
      end
    end

    describe 'merchant fulfills items' do
      it 'has button to fulfill items with sufficient inventory' do
        visit dashboard_order_path(@order)

        within "#oitem-#{@oi1.id}" do
          expect(page).to have_button("Fulfill")
        end

        within "#oitem-#{@oi3.id}" do
          expect(page).to_not have_button("Fulfill")
          expect(page).to have_content("You cannot fulfill this item")
        end
      end

      it 'updates item inventory when order item is fulfilled' do
        visit dashboard_order_path(@order)

        within "#oitem-#{@oi1.id}" do
          click_button("Fulfill")
        end

        expect(current_path).to eq(dashboard_order_path(@order))

        expect(page).to have_content("You have successfully fulfilled an item")
        within "#oitem-#{@oi1.id}" do
          expect(page).to have_content("Fulfilled: Yes")
          expect(page).to_not have_button("Fulfill")
        end
      end

      describe 'sets order as packaged if I am the last merchant to fulfill items' do
        before :each do
          user = create(:user)
          a1 = create(:address, user: user)
          @admin = create(:admin)

          @merchant_1 = create(:merchant)
          create(:address, user: @merchant_1)
          item_1 = create(:item, user: @merchant_1, inventory: 100)
          item_3 = create(:item, user: @merchant_1)

          item_2 = create(:item)

          @order_1 = create(:order, user: user, address: a1)
          @oi_1 = create(:order_item, order: @order_1, item: item_1, price: 1, quantity: 10)
          create(:fulfilled_order_item, order: @order_1, item: item_2, price: 1, quantity: 1)

          @order_2 = create(:order, user: user)
          @oi_3 = create(:order_item, order: @order_2, item: item_3, price: 1, quantity: 1)
        end

        scenario 'as a merchant' do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant_1)
          @am_admin = false
        end

        scenario 'as an admin' do
          allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
          @am_admin = true
        end

        after :each do
          visit @am_admin ? admin_merchant_order_path(@merchant_1, @order_1) : dashboard_order_path(@order_1)
          expect(page).to have_content("Order Status: pending")
          within "#oitem-#{@oi_1.id}" do
            click_button('Fulfill')
          end
          visit @am_admin ? admin_merchant_order_path(@merchant_1, @order_1) : dashboard_order_path(@order_1)
          expect(page).to have_content("Order Status: packaged")

          visit @am_admin ? admin_merchant_order_path(@merchant_1, @order_2) : dashboard_order_path(@order_2)
          expect(page).to have_content("Order Status: pending")
          within "#oitem-#{@oi_3.id}" do
            click_button('Fulfill')
          end
          visit @am_admin ? admin_merchant_order_path(@merchant_1, @order_2) : dashboard_order_path(@order_2)
          expect(page).to have_content("Order Status: packaged")
        end
      end
    end
  end
end
