class Admin::UsersController < Admin::BaseController
  def index
    @users = User.default_users
  end

  def show
    @user = User.find(params[:id])
    @addresses = @user.addresses
    if @user.role == "merchant"
      redirect_to admin_merchant_path(@user)
    end
  end

  def upgrade
    user = User.find(params[:id])
    user.update(role: :merchant)
    flash[:success] = "#{user.name} is now a merchant."
    redirect_to admin_merchant_path(user)
  end
end
