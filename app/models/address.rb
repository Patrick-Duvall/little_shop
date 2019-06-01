class Address < ApplicationRecord
  validates_presence_of :nick_name, :address, :city, :state, :zip
  belongs_to :user
end
