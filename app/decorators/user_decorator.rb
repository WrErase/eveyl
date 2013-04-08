# Decorates a User
class UserDecorator < ApplicationDecorator
  delegate_all

  def last_sign_in_with_ip
    "#{model.last_sign_in_at} (#{model.last_sign_in_ip})"
  end

  def api_keys
    @keys ||= ApiKeyDecorator.decorate(model.api_keys)
  end
end
