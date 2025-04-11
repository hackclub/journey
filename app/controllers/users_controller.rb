class UsersController < ApplicationController
  before_action :authenticate_api_key

  def check_user
    user = User.find_by(slack_id: params[:slack_id])

    if user and user.projects.exists?
      render json: { exists: true, has_project: true, project: user.projects }, status: :ok
    elsif user
      render json: { exists: true, has_project: false }, status: :ok
    else
      render json: { exists: false, has_project: false }, status: :not_found
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
