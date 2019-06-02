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

  def edit
    @address = Address.find(params[:id])
    @user = User.find(params[:user_id])
  end

  def update
    address = Address.find(params[:id])
    address.update(address_params)

    redirect_to profile_path
  end

  def destroy
    address = Address.find(params[:id])
    address.destroy
    redirect_to profile_path

  end

  private
  def address_params
    params.require(:address).permit(:nick_name, :address, :city, :state, :zip)
  end
end
