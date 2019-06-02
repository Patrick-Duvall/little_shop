class User < ApplicationRecord
  has_secure_password

  enum role: [:default, :merchant, :admin]

  validates_presence_of :name
  validates :email, presence: true, uniqueness: true

  # as a consumer
  has_many :addresses
  has_many :orders
  has_many :order_items, through: :orders
  accepts_nested_attributes_for :addresses

  # as a merchant
  has_many :items, foreign_key: 'merchant_id'

  def address
    addresses[0].address
  end
  def city
    addresses[0].city
  end
  def state
    addresses[0].state
  end
  def zip
    addresses[0].zip
  end

  def outstanding_order_count
    items.joins(:order_items).select('order_items.*').where('order_items.fulfilled = false').count
  end
  def outstanding_order_price_sum
    items.joins(:order_items).select('order_items.price, order_items.quantity').where('order_items.fulfilled = false').sum('order_items.price * order_items.quantity')
  end

  def active_items
    items.where(active: true).order(:name)
  end

  def over_ordered_items
    items.joins(:orders)
    .where('orders.status = 0')
    .where('order_items.fulfilled = false')
    .group('items.id')
    .having("sum(order_items.quantity) > items.inventory")
    .select('items.*')

  end

  def top_items_sold_by_quantity(limit)
    items.joins(order_items: :order)
         .where(order_items: {fulfilled: true}, orders: {status: :shipped})
         .select('items.id, items.name, sum(order_items.quantity) as quantity')
         .group(:id)
         .order('quantity DESC, id')
         .limit(limit)
  end

  def total_items_sold
    items.joins(order_items: :order)
         .where(order_items: {fulfilled: true}, orders: {status: :shipped})
         .pluck('sum(order_items.quantity)')
         .first
  end

  def percent_of_items_sold
    ((total_items_sold.to_f / total_inventory_remaining.to_f)*100)
  end

  def total_inventory_remaining
    items.sum(:inventory)
  end

  def top_states_by_items_shipped(limit)
    items.joins(:order_items)
         .joins('join orders on orders.id = order_items.order_id')
         .joins('join users on users.id = orders.user_id')
         .where(order_items: {fulfilled: true}, orders: {status: :shipped})
         .group('users.state')
         .select('users.state, sum(order_items.quantity) AS quantity')
         .order('quantity DESC')
         .limit(limit)
  end

  def top_cities_by_items_shipped(limit)
    items.joins(:order_items)
         .joins('join orders on orders.id = order_items.order_id')
         .joins('join addresses on addresses.id = orders.address_id')
         .where(order_items: {fulfilled: true}, orders: {status: :shipped})
         .group('addresses.state, addresses.city')
         .select('addresses.state, addresses.city, sum(order_items.quantity) AS quantity')
         .order('quantity DESC')
         .limit(limit)
  end

  def top_users_by_money_spent(limit)
    items.joins(:order_items)
        .joins('join orders on orders.id = order_items.order_id')
        .joins('join users on users.id = orders.user_id')
        .where(order_items: {fulfilled: true})
        .group('users.id')
        .select('users.name, sum(order_items.quantity * order_items.price) AS total')
        .order('total DESC')
        .limit(limit)
  end

  def top_user_by_order_count
    items.joins(:order_items)
         .joins('join orders on orders.id = order_items.order_id')
         .joins('join users on users.id = orders.user_id')
         .where(order_items: {fulfilled: true})
         .group('users.id')
         .select('users.name, count(orders.id) AS count')
         .order('count DESC')
         .limit(1).first
  end

  def top_user_by_item_count
    items.joins(:order_items)
         .joins('join orders on orders.id = order_items.order_id')
         .joins('join users on users.id = orders.user_id')
         .where(order_items: {fulfilled: true})
         .group('users.id')
         .select('users.name, sum(order_items.quantity) AS quantity')
         .order('quantity DESC')
         .limit(1).first
  end

  def self.active_merchants
    where(role: :merchant, active: true)
  end

  def self.default_users
    where(role: :default)
  end

  def self.top_merchants_by_revenue(limit)
    merchants_sorted_by_revenue.limit(limit)
  end

  def self.merchants_sorted_by_revenue
    self.joins(:items)
        .joins('join order_items on items.id = order_items.item_id')
        .joins('join orders on orders.id = order_items.order_id')
        .where(orders: {status: :shipped}, order_items: {fulfilled: true})
        .group(:id)
        .select('users.*, sum(order_items.quantity * order_items.price) AS total')
        .order("total DESC")
  end

  def self.merchants_sorted_by_fulfillment_time(limit, order = :asc)
    self.joins(:items)
        .joins('join order_items on items.id = order_items.item_id')
        .joins('join orders on orders.id = order_items.order_id')
        .where.not(orders: {status: :cancelled})
        .where(order_items: {fulfilled: true})
        .group(:id)
        .select('users.*, avg(order_items.updated_at - order_items.created_at) AS fulfillment_time')
        .order("fulfillment_time #{order}")
        .limit(limit)
  end

  def self.top_merchants_by_fulfillment_time(limit)
    merchants_sorted_by_fulfillment_time(limit)
  end

  def self.bottom_merchants_by_fulfillment_time(limit)
    merchants_sorted_by_fulfillment_time(limit, :desc)
  end

  def self.top_user_states_by_order_count(limit)
    self.joins(:orders)
        .where(orders: {status: :shipped})
        .group(:state)
        .select('users.state, count(orders.id) AS order_count')
        .order('order_count DESC')
        .limit(limit)
  end

  def self.top_user_cities_by_order_count(limit)
    self.joins(:orders)
        .where(orders: {status: :shipped})
        .group(:state, :city)
        .select('users.city, users.state, count(orders.id) AS order_count')
        .order('order_count DESC')
        .limit(limit)
  end
end
