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
    address = Address.find(params[:id])
    if address.editable?
      @address = address
      @user = User.find(params[:user_id])
    else
      flash[:warning] = "Cannot Edit #{address.nick_name}, it is associated with a packaged or shipped order"
      redirect_to profile_path
    end
  end

  def update
    address = Address.find(params[:id])
    if address.editable?
    address.update(address_params)
    redirect_to profile_path
    else
      flash[:warning] = "Cannot Edit #{address.nick_name}, it is associated with a packaged or shipped order"
      redirect_to profile_path
    end
  end

  def destroy
    address = Address.find(params[:id])
    if address.editable?
      address.orders.each{|order| order.update(address_id: nil)}
      address.destroy
      redirect_to profile_path
    else
      flash[:warning] = "Cannot Delete #{address.nick_name}, it is associated with a packaged or shipped order"
      redirect_to profile_path
    end

  end

  private
  def address_params
    params.require(:address).permit(:nick_name, :address, :city, :state, :zip)
  end
end
