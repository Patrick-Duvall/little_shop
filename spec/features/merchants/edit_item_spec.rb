require 'rails_helper'

RSpec.describe "Merchant editing an item" do
  before :each do
    @merchant = create(:merchant)
    create(:address, user: @merchant)
    @item = create(:item, user: @merchant)
    @updated_name = "updated name"
    @updated_description = "updated description"
    @updated_price = "99.99"
    @updated_inventory = "567865"
    @updated_image = "https://picsum.photos/200/300?image=1000"
    login_as(@merchant)
    visit dashboard_items_path
    within "#item-#{@item.id}" do
      click_link "edit"
    end
  end

  describe "happy path" do
    it "has a form prepopulated with the item data" do
      expect(current_path).to eq(edit_dashboard_item_path(@item))

      expect(page).to have_css("[@value='#{@item.name}']")
      expect(page).to have_css("[@value='#{@item.description}']")
      expect(page).to have_css("[@value='#{@item.price}']")
      expect(page).to have_css("[@value='#{@item.inventory}']")
      expect(page).to have_css("[@value='#{@item.image}']")
    end

    it "can edit an item" do
      fill_in :item_name, with: @updated_name
      fill_in :item_description, with: @updated_description
      fill_in :item_price, with: @updated_price
      fill_in :item_inventory, with: @updated_inventory
      fill_in :item_image, with: @updated_image

      click_button "Update Item"

      expect(current_path).to eq(dashboard_items_path)
      expect(page).to have_content("Your Item has been updated!")

      within "#item-#{@item.id}" do
        expect(page).to have_content(@updated_name)
        expect(page).to have_content(@updated_price)
        expect(page).to have_content(@updated_inventory)
        expect(page).to have_xpath("//img[@src='#{@updated_image}']")
        expect(page).to have_button("Disable Item")
      end
    end

    it "can leave image blank" do
      fill_in :item_image, with: ""
      click_button "Update Item"

      expect(page).to have_content("Your Item has been updated!")

      within "#item-#{@item.id}" do
        expect(page).to have_xpath("//img[@src='https://picsum.photos/200/300']")
      end
    end
  end

  describe "sad path" do
    it "cannot leave fields blank" do
      fill_in :item_name, with: ""
      fill_in :item_description, with: ""
      fill_in :item_price, with: ""
      fill_in :item_inventory, with: ""
      click_button "Update Item"

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Description can't be blank")
      expect(page).to have_content("Price can't be blank")
      expect(page).to have_content("Inventory can't be blank")
    end

    it "cannot enter price less than or equal to 0" do
      fill_in :item_price, with: "0"
      click_button "Update Item"

      expect(page).to have_content("Price must be greater than 0")
    end

    it "cannot enter inventory less than 0" do
      fill_in :item_inventory, with: "-1"
      click_button "Update Item"

      expect(page).to have_content("Inventory must be greater than or equal to 0")
    end
  end

  it "repopulates fields with current data when update is unsucessfull" do
    fill_in :item_name, with: ""
    fill_in :item_description, with: ""
    fill_in :item_price, with: ""
    fill_in :item_inventory, with: ""
    click_button "Update Item"

    expect(page).to have_css("[@value='#{@item.name}']")
    expect(page).to have_css("[@value='#{@item.description}']")
    expect(page).to have_css("[@value='#{@item.price}']")
    expect(page).to have_css("[@value='#{@item.inventory}']")
    expect(page).to have_css("[@value='#{@item.image}']")
  end
end
