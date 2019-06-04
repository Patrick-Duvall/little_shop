require "rails_helper"

RSpec.describe Address, type: :model do
  describe 'validations' do
    it { should validate_presence_of :nick_name }
    it { should validate_presence_of :address }
    it { should validate_presence_of :city }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many :orders }
  end

  describe "instance methods" do
    it ".editable?" do
      user = create(:user)
      address = create(:address, user: user)
      address2 = create(:address, user: user, nick_name: 'school')
      address3 = create(:address, user: user, nick_name: 'work')
      address4 = create(:address, user: user, nick_name: 'other')
      pending_order = create(:order, user: user, address: address)
      pending_order2 = create(:order, user: user, address: address2)
      packaged_order = create(:packaged_order, user: user, address: address2)
      shipped_order = create(:shipped_order, user: user, address: address3)
      cancelled_order = create(:cancelled_order, user: user, address: address4)
      expect(address.editable?).to eq(true)
      expect(address2.editable?).to eq(false)
      expect(address3.editable?).to eq(false)
      expect(address4.editable?).to eq(true)
    end

  end
end
