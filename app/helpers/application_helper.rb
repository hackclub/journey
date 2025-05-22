module ApplicationHelper
  include MarkdownHelper
  include Pagy::Frontend

  def mobile_device?
    request.user_agent&.match?(
      /Mobile|webOS|iPhone|iPad|iPod|Android|BlackBerry|IEMobile|Opera Mini/i
    )
  end

  def format_seconds(seconds)
    return "0h 0m" if seconds.nil? || seconds == 0

    hours = seconds / 3600
    minutes = (seconds % 3600) / 60

    "#{hours}h #{minutes}m"
  end

  def admin_tool(class_name = "", element = "div", **options, &block)
    return unless current_user&.is_admin?
    concat content_tag(element, class: "p-2 border-4 border-dashed border-orange-500 bg-orange-500/10 #{class_name}", **options, &block)
  end
end
