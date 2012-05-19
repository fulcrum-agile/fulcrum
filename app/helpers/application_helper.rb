module ApplicationHelper
  def show_messages
    content_tag :div, nil, { :id => 'messages' } do
      flash.collect { |index, value| content_tag(:div, value, {:class => "flash-" + index.to_s}) }.join.html_safe
    end unless flash.blank?
  end
  
  def page_id
    "#{controller_name}_#{action_name}"
  end
end
