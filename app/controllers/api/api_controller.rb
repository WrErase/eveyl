class Api::ApiController < ActionController::Metal
  include AbstractController::Rendering
  include AbstractController::ViewPaths
  include AbstractController::Callbacks
  include AbstractController::Helpers

  include ActiveSupport::Rescuable

  include ActionController::Rendering
  include ActionController::ImplicitRender
  include ActionController::Rescue
  include ActionController::MimeResponds

  include ActionController::Head

  include Devise::Controllers::Helpers

  include Rails.application.routes.url_helpers

  append_view_path File.expand_path("../../../app/views", File.dirname(__FILE__))

  before_filter :parse_pagination
  before_filter :set_content_type

  rescue_from ActionController::RoutingError, :with => :not_found
  rescue_from ActiveRecord::RecordNotFound, :with => :not_found

  respond_to :json

  def not_found
    head :not_found and return
  end

  def invalid_query
    head :bad_request
  end

  protected

  def parse_pagination
    if datatable_query?
      options = DataTable.table_to_pages(params)
      @page = [options.page.to_i, 1].max
      @rpp  = options.per_page.to_i
    else
      @page = [params[:page].to_i, 1].max
      @rpp  = params[:per_page].to_i
    end

    @rpp = 200 if @rpp <= 0 || @rpp > 200
  end

  def set_content_type
    self.content_type = 'application/json'
  end

  def datatable_query?
    params[:iDisplayStart] || params[:iDisplayLength]
  end
end
