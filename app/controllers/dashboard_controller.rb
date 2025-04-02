class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @recent_projects = Project.includes(:user)
                            .order(created_at: :desc)
                            .limit(5)

    @top_rated_projects = Project.includes(:user)
                                .order(rating: :desc)
                                .limit(5)

    @recent_updates = Update.includes(:project, :user)
                           .order(created_at: :desc)
                           .limit(10)

    @total_projects = Project.count
    @total_users = User.count
    @total_updates = Update.count
  end
end
