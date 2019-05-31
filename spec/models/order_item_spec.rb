require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  describe 'validations' do
    it { should validate_presence_of :price }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of :quantity }
    it { should validate_numericality_of(:quantity).only_integer }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(1) }
  end

  describe 'relationships' do
    it { should belong_to :order }
    it { should belong_to :item }
  end

  describe 'instance methods' do
    it '.subtotal' do
      oi = create(:order_item, quantity: 5, price: 3)

      expect(oi.subtotal).to eq(15)
    end

    it '.fulfill' do
      item = create(:item, inventory:2)
      oi1 = create(:order_item, quantity: 1, item: item)
      oi2 = create(:order_item, quantity: 1, item: item)
      oi3 = create(:order_item, quantity: 1, item: item)

      oi1.fulfill

      expect(oi1.fulfilled).to eq(true)
      expect(item.inventory).to eq(1)

      oi2.fulfill

      expect(oi1.fulfilled).to eq(true)
      expect(item.inventory).to eq(0)

      oi2.fulfill

      expect(oi2.fulfilled).to eq(true)
      expect(item.inventory).to eq(0)

      oi3.fulfill

      expect(oi2.fulfilled).to eq(true)
      expect(item.inventory).to eq(0)
    end

    it '.item_name' do
      merchant = create(:merchant)
      i1 = create(:item, user: merchant)
      oi1 = create(:order_item, quantity: 1, item: i1)

      expect(oi1.item_name).to eq(i1.name)
    end

    it 'inventory_available' do
      item = create(:item, inventory:2)
      oi1 = create(:order_item, quantity: 1, item: item)
      oi2 = create(:order_item, quantity: 2, item: item)
      oi3 = create(:order_item, quantity: 3, item: item)

      expect(oi1.inventory_available).to eq(true)
      expect(oi2.inventory_available).to eq(true)
      expect(oi3.inventory_available).to eq(false)
    end

  end
end
