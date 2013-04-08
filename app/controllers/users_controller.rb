class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :create]

  respond_to :html

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.admin = true if User.count == 0

    if @user.save
      redirect_to root_url, notice: "Signed up!"
    else
      render "new"
    end
  end

  def show
    @user = UserDecorator.decorate(current_user)
    @regions = Region.select_map
    @order_stats = OrderStat.select_map

    respond_with @user
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
