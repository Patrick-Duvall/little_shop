require 'rails_helper'

RSpec.describe "Merchant index page" do
  before :each do
    @merchant = create(:merchant)
    create(:address, user: @merchant)
    @item_1, @item_2 = create_list(:item, 2, user: @merchant)
    @item_3 = create(:inactive_item, user: @merchant)
    @order_1, @order_2 = create_list(:order, 2)
    @order_3 = create(:shipped_order)
    @order_4 = create(:cancelled_order)
    create(:order_item, order: @order_1, item: @item_1, quantity: 1, price: 2)
    create(:order_item, order: @order_1, item: @item_2, quantity: 2, price: 2)
    create(:order_item, order: @order_2, item: @item_2, quantity: 4, price: 2)
    create(:order_item, order: @order_3, item: @item_1, quantity: 4, price: 2)
    create(:order_item, order: @order_4, item: @item_2, quantity: 5, price: 2)

    login_as(@merchant)
    visit dashboard_items_path
  end

  it "has a link to add a new item" do
    expect(page).to have_link("Add new Item")
  end

  it "shows all the merchants items" do
    within("#item-#{@item_1.id}") do
      expect(page).to have_content("ID: #{@item_1.id}")
      expect(page).to have_content(@item_1.name)
      expect(page).to have_xpath("//img[@src='#{@item_1.image}']")
      expect(page).to have_content(@item_1.price)
      expect(page).to have_content(@item_1.inventory)
      expect(page).to have_link("edit")
    end

    within("#item-#{@item_2.id}") do
      expect(page).to have_content("ID: #{@item_2.id}")
      expect(page).to have_content(@item_2.name)
      expect(page).to have_xpath("//img[@src='#{@item_2.image}']")
      expect(page).to have_content(@item_2.price)
      expect(page).to have_content(@item_2.inventory)
      expect(page).to have_link("edit")
    end

    within("#item-#{@item_3.id}") do
      expect(page).to have_content("ID: #{@item_3.id}")
      expect(page).to have_content(@item_3.name)
      expect(page).to have_xpath("//img[@src='#{@item_3.image}']")
      expect(page).to have_content(@item_3.price)
      expect(page).to have_content(@item_3.inventory)
      expect(page).to have_link("edit")
    end
  end

  it "has a delete link for items that have never been ordered" do
    within("#item-#{@item_1.id}") do
      expect(page).to_not have_button("Delete Item")
    end

    within("#item-#{@item_2.id}") do
      expect(page).to_not have_button("Delete Item")
    end

    within("#item-#{@item_3.id}") do
      expect(page).to have_button("Delete Item")
    end
  end

  it "has buttons to enable/disable items" do
    within("#item-#{@item_1.id}") do
      expect(page).to have_button("Disable Item")
    end

    within("#item-#{@item_2.id}") do
      expect(page).to have_button("Disable Item")
    end

    within("#item-#{@item_3.id}") do
      expect(page).to have_button("Enable Item")
    end
  end
end
