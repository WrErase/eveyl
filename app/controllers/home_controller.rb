class HomeController < ApplicationController
  respond_to :json, :html
  def index
    begin
      @minerals = OrderStat.minerals_for_hubs

      if current_user
        @default_stat = current_user.user_profile.default_stat
      else
        @default_stat = 'weighted_avg'
      end
    rescue ActiveRecord::RecordNotFound
      @minerals = nil
    end

    respond_with @minerals
  end
end
