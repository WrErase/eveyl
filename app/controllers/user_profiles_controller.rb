class UserProfilesController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :create]

  respond_to :html

  def show
    respond_with current_user
  end

  def update
    if current_user.user_profile.update_attributes(set_params)
      Rails.logger.debug current_user
      redirect_to :user
    end
  end

  def set_params
    params.require(:user_profile).permit(:default_region, :default_stat)
  end
end
