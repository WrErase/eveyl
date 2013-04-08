class ApiLogsController < ApplicationController
  respond_to :html

  def index
    @api_logs = ApiLog.recent

    respond_with @api_logs
  end
end
