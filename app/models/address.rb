class Address < ApplicationRecord
  validates_presence_of :nick_name, :address, :city, :state, :zip
  belongs_to :user
  has_many :orders

  def editable?
    orders.select(:status).where(status: [1, 2]).empty?
  end
end
