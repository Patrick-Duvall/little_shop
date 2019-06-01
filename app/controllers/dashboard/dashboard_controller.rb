class Dashboard::DashboardController < Dashboard::BaseController
  def index
    @merchant = current_user
    @merchant.over_ordered_items.each do |item|
      flash["item#{item.id}"] = "Cannot fulfill all orders of #{item.name}"
    end
    @pending_orders = Order.pending_orders_for_merchant(current_user.id)
    @items = @merchant.items
  end
end

# items.joins( :orders).where('orders.status = 0').where('sum(order_items.quantity) > items.inventory')

# Product.joins(:sales).
#         group("sales.product_id").
#         having("sum(sales.quantity) < sum(products.quantity)").
#         select("products.*")
