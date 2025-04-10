module ApplicationHelper
  def mobile_device?
    request.user_agent&.match?(
      /Mobile|webOS|iPhone|iPad|iPod|Android|BlackBerry|IEMobile|Opera Mini/i
    )
  end
end
