class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  validates :price, presence: true, numericality: {
    only_integer: false,
    greater_than_or_equal_to: 0
  }
  validates :quantity, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1
  }

  def subtotal
    quantity * price
  end

  def item_name
    item.name
  end

  def fulfill
    if item.inventory >= quantity && !self.fulfilled
      item.inventory -= quantity
      self.fulfilled = true
      item.save
      save
    end
  end

  def inventory_available
    item.inventory >= quantity
  end
end
