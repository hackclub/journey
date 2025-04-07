class ProjectsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_project, only: [:show, :edit, :update]
    
    def index
        @projects = Project.includes(:user)
                          .order(rating: :desc)
    end

    def show
        @updates = @project.updates.order(created_at: :desc)

        respond_to do |format|
            format.html
            format.turbo_stream
        end
    end

    def edit
        unless current_user == @project.user
            redirect_to project_path(@project), alert: "You can only edit your own projects."
        end
    end

    def update
        if current_user == @project.user
            if @project.update(project_params)
                redirect_to project_path(@project), notice: "Project was successfully updated."
            else
                render :edit, status: :unprocessable_entity
            end
        else
            redirect_to project_path(@project), alert: "You can only edit your own projects."
        end
    end

    def create
        @project = current_user.projects.build(project_params)

        respond_to do |format|
            if @project.save
                format.html { redirect_to project_path(@project), notice: "Project was successfully created." }
                format.turbo_stream { redirect_to project_path(@project), notice: "Project was successfully created." }
            else
                @projects = current_user.projects
                format.html {
                    flash.now[:alert] = "Could not create project. Please check the form for errors."
                    render :index, status: :unprocessable_entity
                }
                format.turbo_stream {
                    flash.now[:alert] = "Could not create project. Please check the form for errors."
                    render :index, status: :unprocessable_entity
                }
            end
        end
    end

    def my_projects
        @projects = current_user.projects
        render :index
    end

    private

    def set_project
        @project = Project.includes(:user, updates: :user).find(params[:id])
    end

    def project_params
        params.require(:project).permit(:title, :description, :readme_link, :demo_link, :repo_link, :banner)
    end
end
