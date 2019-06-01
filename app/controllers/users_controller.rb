class UsersController < ApplicationController
  before_action :require_reguser, except: [:new, :create]

  def new
    @user = User.new
  end

  def show
    @user = current_user
    @addresses = @user.addresses
  end

  def edit
    @user = current_user
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Registration Successful! You are now logged in."
      redirect_to profile_path
    else
      flash.now[:danger] = @user.errors.full_messages
      @user.update(email: "", password: "")
      render :new
    end
  end

  def update
    @user = current_user
    @user.update(user_update_params)
    if @user.save
      flash[:success] = "Your profile has been updated"
      redirect_to profile_path
    else
      flash.now[:danger] = @user.errors.full_messages
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :address, :city, :state, :zip, :email, :password, :password_confirmation)
  end

  def user_update_params
    uup = user_params
    uup.delete(:password) if uup[:password].empty?
    uup.delete(:password_confirmation) if uup[:password_confirmation].empty?
    uup
  end
end
