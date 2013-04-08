class CharacterAssetsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :verify_character

  respond_to :html, :json

  def search
    if params[:character_id]
      ids = [params[:character_id].to_i]
    else
      ids = current_user.character_ids
    end

    search = AssetsSearch.new(character_ids: ids,
                              query: params[:search])
    @assets = CharacterAssetDecorator.decorate(search.build_query)

    respond_with @assets
  end

  def index
    if params[:character_id]
      character_ids = [params[:character_id]]
    else
      character_ids = current_user.character_ids
    end

    search = AssetsSearch.new(character_ids: character_ids)
    @assets = CharacterAssetDecorator.decorate_collection(search.build_query)

    respond_with @assets
  end

  protected

  def verify_character
    return unless params[:character_id]

    unless current_user.has_character?(params[:character_id].to_i)
      return redirect_to :back, alert: 'Permission Denied'
    end
  end
end
