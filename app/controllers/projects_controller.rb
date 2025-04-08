class ProjectsController < ApplicationController
    include ActionView::RecordIdentifier
    before_action :authenticate_user!
    before_action :set_project, only: [:show, :edit, :update, :follow, :unfollow]
    
    def index
        @projects = Project.includes(:user)
                          .where.not(user_id: current_user.id)
                          .order(rating: :desc)
        @followed_project_ids = current_user.project_follows.pluck(:project_id)
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
    # Gotta say I love turbo frames and turbo streams and flashes in general
    def follow
        @project_follow = current_user.project_follows.build(project: @project)
        
        respond_to do |format|
            if @project_follow.save
                format.html { redirect_to projects_path, notice: "You are now following this project!" }
                format.turbo_stream do
                    flash.now[:notice] = "You are now following this project!"
                    render turbo_stream: [
                        turbo_stream.update("flash-container", partial: "shared/flash"),
                        turbo_stream.replace(dom_id(@project, :follow_button), 
                            partial: "projects/follow_button", 
                            locals: { project: @project, following: true }
                        )
                    ]
                end
            else
                error_message = @project_follow.errors.full_messages.join(', ')
                format.html { redirect_to projects_path, alert: "Could not follow project: #{error_message}" }
                format.turbo_stream do
                    flash.now[:alert] = "Could not follow project: #{error_message}"
                    render turbo_stream: [
                        turbo_stream.update("flash-container", partial: "shared/flash"),
                        turbo_stream.replace(dom_id(@project, :follow_button), 
                            partial: "projects/follow_button", 
                            locals: { project: @project, following: false }
                        )
                    ]
                end
            end
        end
    end

    def unfollow
        @project_follow = current_user.project_follows.find_by(project: @project)
        
        respond_to do |format|
            if @project_follow&.destroy
                format.html { redirect_to projects_path, notice: "You have unfollowed this project." }
                format.turbo_stream do
                    flash.now[:notice] = "You have unfollowed this project."
                    render turbo_stream: [
                        turbo_stream.update("flash-container", partial: "shared/flash"),
                        turbo_stream.replace(dom_id(@project, :follow_button), 
                            partial: "projects/follow_button", 
                            locals: { project: @project, following: false }
                        )
                    ]
                end
            else
                format.html { redirect_to projects_path, alert: "Could not unfollow project." }
                format.turbo_stream do
                    flash.now[:alert] = "Could not unfollow project."
                    render turbo_stream: [
                        turbo_stream.update("flash-container", partial: "shared/flash"),
                        turbo_stream.replace(dom_id(@project, :follow_button), 
                            partial: "projects/follow_button", 
                            locals: { project: @project, following: true }
                        )
                    ]
                end
            end
        end
    end

    private

    def set_project
        @project = Project.includes(:user, updates: :user).find(params[:id])
    end

    def project_params
        params.require(:project).permit(:title, :description, :readme_link, :demo_link, :repo_link, :banner)
    end
end
