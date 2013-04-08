# Create/Destroy a user's API Keys
class ApiKeysController < ApplicationController
  before_filter :find_key, only: [:show, :destroy]
  before_filter :authenticate_user!

  respond_to :html

  def show
    respond_with @key
  end

  def new
    render :partial => "users/api_key_form_modal", :locals => {:api_key => @api_key}
  end

  def create
    @api_key = current_user.api_keys.build(api_key_params)

    @key_passed = @api_key.test_key if @api_key.valid?

    if @key_passed && @api_key.save
      flash[:notice] = 'Added API Key'
      render :nothing => true, :status => 201
    else
      if request.xhr?
        render :partial => "users/api_key_form_modal", :locals => {:api_key => @api_key}, :status => :bad_request
      else
        redirect_to user_path, alert: "Key Creation Failed"
      end
    end
  end

  def destroy
    if @key.destroy
      redirect_to user_path, notice: "Key Deleted"
    else
      redirect_to user_path, notice: "Key Deletion Failed"
    end
  end

  private

  def find_key
    @key = current_user.api_keys.find(params[:id])

    unless @key
      redirect_to user_path(current_user), alert: "Key Not Found"
    end
  end

  def api_key_params
    params.require(:api_key).permit(:key_id, :vcode)
  end
end
