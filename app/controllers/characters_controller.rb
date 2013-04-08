class CharactersController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :json

  def index
    @accounts = AccountDecorator.decorate_collection(current_user.accounts)

    respond_with @accounts
  end

  def show
    @character = current_user.characters.find(params[:id])
    @skills = CharacterSkill.group_by_type(@character.character_id)

    respond_with @character
  end
end
