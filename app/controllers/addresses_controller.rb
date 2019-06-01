class AddressesController < ApplicationController
  def new
    @user = User.find(params[:user_id])
    @address = Address.new
  end

  def create
    @user = User.find(params[:user_id])
    @user.addresses.create!(address_params)
    redirect_to profile_path
  end

  private
  def address_params

    params.require(:address).permit(:nick_name, :address, :city, :state, :zip)
  end
end
