require 'rails_helper'

RSpec.describe 'merchant dashboard' do

  before :each do
    @merchant = create(:merchant)
    @admin = create(:admin)
    @i1, @i2 = create_list(:item, 2, user: @merchant)
    @i3 = create(:item, user: @merchant, image:"http://clipart-library.com/images/6Tpo6G8TE.jpg")

    @o1, @o2 = create_list(:order, 2)
    @o3 = create(:shipped_order)
    @o4 = create(:cancelled_order)
    @oi1 = create(:order_item, order: @o1, item: @i1, quantity: 1, price: 2)
    @oi2 = create(:order_item, order: @o1, item: @i2, quantity: 2, price: 2)
    @oi3 = create(:order_item, order: @o2, item: @i2, quantity: 4, price: 2)
    @oi4 = create(:order_item, order: @o3, item: @i1, quantity: 4, price: 2)
    @oi5 = create(:order_item, order: @o4, item: @i2, quantity: 5, price: 2)
  end

  describe 'merchant user visits their profile' do
    describe 'shows merchant information' do
      scenario 'as a merchant' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_path
        expect(page).to_not have_button("Downgrade to User")
      end
      scenario 'as an admin' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
        visit admin_merchant_path(@merchant)
      end
      after :each do
        expect(page).to have_content(@merchant.name)
        expect(page).to have_content("Email: #{@merchant.email}")
        expect(page).to have_content("Address: #{@merchant.address}")
        expect(page).to have_content("City: #{@merchant.city}")
        expect(page).to have_content("State: #{@merchant.state}")
        expect(page).to have_content("Zip: #{@merchant.zip}")
      end
    end
  end

  describe 'merchant user with orders visits their profile' do
    before :each do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

      visit dashboard_path
    end
    it 'shows merchant information' do
      expect(page).to have_content(@merchant.name)
      expect(page).to have_content("Email: #{@merchant.email}")
      expect(page).to have_content("Address: #{@merchant.address}")
      expect(page).to have_content("City: #{@merchant.city}")
      expect(page).to have_content("State: #{@merchant.state}")
      expect(page).to have_content("Zip: #{@merchant.zip}")
    end

    it 'does not have a link to edit information' do
      expect(page).to_not have_link('Edit')
    end

    it 'shows pending order information' do
      within("#order-#{@o1.id}") do
        expect(page).to have_link(@o1.id)
        expect(page).to have_content(@o1.created_at)
        expect(page).to have_content(@o1.total_quantity_for_merchant(@merchant.id))
        expect(page).to have_content(@o1.total_price_for_merchant(@merchant.id))
      end
      within("#order-#{@o2.id}") do
        expect(page).to have_link(@o2.id)
        expect(page).to have_content(@o2.created_at)
        expect(page).to have_content(@o2.total_quantity_for_merchant(@merchant.id))
        expect(page).to have_content(@o2.total_price_for_merchant(@merchant.id))
      end
    end

    it 'does not show non-pending orders' do
      expect(page).to_not have_css("#order-#{@o3.id}")
      expect(page).to_not have_css("#order-#{@o4.id}")
    end

    describe 'shows a link to merchant items' do
      scenario 'as a merchant' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)
        visit dashboard_path
        click_link('Items for Sale')
        expect(current_path).to eq(dashboard_items_path)
      end
      scenario 'as an admin' do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)
        visit admin_merchant_path(@merchant)
        expect(page.status_code).to eq(200)
        click_link('Items for Sale')
        expect(current_path).to eq(admin_merchant_items_path(@merchant))
      end
    end

    describe "merchant is prompted to add image" do
      it "shows a list of items with default image" do
        visit dashboard_path
        within "#add-image" do
          expect(page).to have_content("These items need images:")
          expect(page).to_not have_content(@i3.name)
          click_link @i1.name
        end
        expect(current_path).to eq(edit_dashboard_item_path(@i1))
        visit dashboard_path
        within "#add-image" do
          click_link @i2.name
          expect(page).to_not have_content(@i3.name)
        end
          expect(current_path).to eq(edit_dashboard_item_path(@i2))
      end
    end

    describe "merchant sees a sum outstanding orders statistic" do
      it "shows me a sum of my outstanding orders totals" do
        visit dashboard_path
        within "#unfulfilled-orders-price-and-number" do
          expect(page).to have_content("You have #{@merchant.outstanding_order_count} unfulfilled orders worth #{ActiveSupport::NumberHelper.number_to_currency(@merchant.outstanding_order_price_sum)}")
        end
      end
    end

#     As a Merchant, When I visit my dashboard
# -Next to each order, I see a warning if that items quantity exceeds my inventory

    describe "I am warned of items I cannot fulfill" do
      it "says which orders I cannot fulfill" do
        oi6 = create(:order_item, order: @o1, item: @i3, quantity: 10, price: 2)
        oi7 = create(:order_item, order: @o1, item: @i2, quantity: 10, price: 2)
        visit dashboard_path
        save_and_open_page
        within "#order-#{@o1.id}" do
          expect(page).to have_content("Insufficient inventory of #{@i3.name}")
          expect(page).to have_content("Insufficient inventory of #{@i2.name}")
          expect(page).to_not  have_content("Insufficient inventory of #{@i1.name}")
        end
      end
    end

  end
end
