class ProjectsController < ApplicationController
    before_action :authenticate_user!
    def index
        @projects = Project.includes(:user) 
                          .order(rating: :desc)  
    end

    def my_projects
        @projects = current_user.projects
        render :index 
    end
end
