class UsersController < ApplicationController
  before_action :authenticate_api_key, only: [ :check_user ]
  before_action :authenticate_user!, only: [ :update_hackatime_confirmation, :refresh_hackatime, :check_hackatime_connection ]

  def check_user
    user = User.find_by(slack_id: params[:slack_id])

    if user and user.projects.any?
      render json: { exists: true, has_project: true, projects: user.projects }, status: :ok
    elsif user
      render json: { exists: true, has_project: false }, status: :ok
    else
      render json: { exists: false, has_project: false }, status: :not_found
    end
  end

  def update_hackatime_confirmation
    current_user.update(hackatime_confirmation_shown: true)
    redirect_back_or_to root_path
  end

  def refresh_hackatime
    current_user.refresh_hackatime_data
    redirect_back_or_to root_path, notice: "Hackatime data refresh has been initiated. It may take a few moments to complete."
  end

  def check_hackatime_connection
    User.check_hackatime(current_user.slack_id)

    current_user.reload

    if current_user.has_hackatime
      current_user.update(hackatime_confirmation_shown: true) unless current_user.hackatime_confirmation_shown
      redirect_back_or_to root_path, notice: "Successfully connected to Hackatime! Your coding stats are now being tracked."
    else
      redirect_back_or_to root_path, alert: "No Hackatime connection found. Please sign up at Hackatime with your Slack account and try again."
    end
  end

  private

  def authenticate_api_key
    api_key = request.headers["Authorization"]
    unless api_key.present? && api_key == ENV["API_KEY"]
        render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
