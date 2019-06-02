require 'rails_helper'

RSpec.describe 'Downgrade Merchant to User' do
  describe 'As an admin' do
    describe 'from the admin merchant dashboard (show)' do
      it 'can click button to downgrade a merchant' do
        admin = create(:admin)
        merchant = create(:merchant)
        create(:address, user: merchant)

        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin)

        visit admin_merchant_path(merchant)

        click_button 'Downgrade to User'

        expect(current_path).to eq(admin_user_path(merchant))

        visit admin_users_path

        expect(page).to have_css("#user-#{merchant.id}")
      end
    end
  end
end
