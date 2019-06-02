require 'rails_helper'

RSpec.describe 'Site Nav', type: :feature do
  before :each do
    @user = create(:user)
    create(:address, user: @user)
    @user_2 = create(:user)
    create(:address, user: @user_2)
    @merchant = create(:merchant)
    create(:address, user: @merchant)
    @admin = create(:admin)

    item_1 = create(:item, user: @merchant)
    order = create(:shipped_order, user: @user)
    create(:fulfilled_order_item, order: order, item: item_1, price: 1, quantity: 1, created_at: 2.days.ago, updated_at: 1.minutes.ago)
  end

  it 'should show proper links for all visitors' do
    visit root_path

    click_link 'Items'
    expect(current_path).to eq(items_path)

    click_link 'Merchants'
    expect(current_path).to eq(merchants_path)

    click_link 'Cart: 0'
    expect(current_path).to eq(cart_path)

    click_link 'Log in'
    expect(current_path).to eq(login_path)

    click_link 'Register'
    expect(current_path).to eq(registration_path)

    click_link 'Home'
    expect(current_path).to eq(root_path)

    expect(page).to_not have_link('Log out')
    expect(page).to_not have_link('Profile')
    expect(page).to_not have_link('Dashboard')
    expect(page).to_not have_link('Users')

    visit profile_path
    expect(page.status_code).to eq(404)
    visit dashboard_path
    expect(page.status_code).to eq(404)
    visit admin_dashboard_path
    expect(page.status_code).to eq(404)
    visit admin_users_path
    expect(page.status_code).to eq(404)
    visit admin_user_path(@user)
    expect(page.status_code).to eq(404)
    visit admin_merchant_path(@merchant)
    expect(page.status_code).to eq(404)
  end

  it 'should show proper links for all users logged in' do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user)

    visit root_path

    click_link 'Profile'
    expect(current_path).to eq(profile_path)

    click_link 'Orders'
    expect(current_path).to eq(profile_orders_path)

    click_link 'Log out'
    expect(current_path).to eq(root_path)

    expect(page).to_not have_link('Log in')
    expect(page).to_not have_link('Register')
    expect(page).to_not have_link('Dashboard')
    expect(page).to_not have_link('Users')

    visit dashboard_path
    expect(page.status_code).to eq(404)
    visit admin_dashboard_path
    expect(page.status_code).to eq(404)
    visit admin_users_path
    expect(page.status_code).to eq(404)
    visit admin_user_path(@user)
    expect(page.status_code).to eq(404)
    visit admin_merchant_path(@merchant)
    expect(page.status_code).to eq(404)
    visit admin_dashboard_path
    expect(page.status_code).to eq(404)
  end

  it 'should show proper links for all merchants logged in' do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@merchant)

    visit root_path

    click_link 'Dashboard'
    expect(current_path).to eq(dashboard_path)

    expect(page).to_not have_link('Profile')
    expect(page).to_not have_link('Cart: 0')
    expect(page).to_not have_link('Log In')
    expect(page).to_not have_link('Register')

    visit profile_path
    expect(page.status_code).to eq(404)
    visit cart_path
    expect(page.status_code).to eq(404)
    visit cart_path
    expect(page.status_code).to eq(404)
    visit admin_dashboard_path
    expect(page.status_code).to eq(404)
    visit admin_users_path
    expect(page.status_code).to eq(404)
    visit admin_user_path(@user)
    expect(page.status_code).to eq(404)
    visit admin_merchant_path(@merchant)
    expect(page.status_code).to eq(404)
    visit admin_dashboard_path
    expect(page.status_code).to eq(404)
  end

  it 'should show proper links for all admins logged in' do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

    visit root_path

    click_link 'Users'
    expect(current_path).to eq(admin_users_path)

    click_link 'Dashboard'
    expect(current_path).to eq(admin_dashboard_path)

    expect(page).to_not have_link('Profile')
    expect(page).to_not have_link('Cart: 0')
    expect(page).to_not have_link('Log In')
    expect(page).to_not have_link('Register')

    visit cart_path
    expect(page.status_code).to eq(404)
    visit dashboard_path
    expect(page.status_code).to eq(404)
    visit profile_path
    expect(page.status_code).to eq(404)
    visit cart_path
    expect(page.status_code).to eq(404)
  end

  it 'redirects admin to correct user or merchant page' do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@admin)

    visit admin_merchant_path(@user)
    expect(current_path).to eq(admin_user_path(@user))

    visit admin_user_path(@merchant)
    expect(current_path).to eq(admin_merchant_path(@merchant))
  end
end
