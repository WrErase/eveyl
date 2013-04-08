class ApiKeyDecorator < ApplicationDecorator
  delegate_all

  def expires
    return '' unless model.expires

    model.expires.strftime("%F")
  end
end
