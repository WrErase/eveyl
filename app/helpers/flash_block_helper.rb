module FlashBlockHelper
  def flash_block
    output = ''
    flash.reject { |k,v| v.nil? || v.to_s.empty?}.each do |type, message|
      output += flash_container(type, message)
    end

    raw(output)
  end

  def flash_container(type, message)
    if [:alert, :error].include?(type)
      heading = content_tag(:h4, type.to_s.capitalize, :class => 'alert-heading')
    end

    dismiss = content_tag(:a, raw("&times;"),:class => 'close', :data => {:dismiss => 'alert'})

    raw(content_tag(:div, :class => "alert alert-#{type}") do
      heading ? dismiss + heading + message : dismiss + raw(message)
    end)
  end
end
