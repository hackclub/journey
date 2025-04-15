class ProjectsController < ApplicationController
    include ActionView::RecordIdentifier
    before_action :authenticate_user!
    before_action :set_project, only: [ :show, :edit, :update, :follow, :unfollow ]

    def index
        @projects = Project.includes(:user)
                          .where.not(user_id: current_user.id)
                          .order(rating: :desc)

        @projects = @projects.sort_by do |project|
            weight = rand + (project.updates.count > 0 ? 1.5 : 0)
            -weight
        end

        if params[:action] == "my_projects" && @projects.empty?
            @show_create_project = true
        end
    end

    def show
        @updates = @project.updates.order(created_at: :desc)
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
            redirect_to project_path(@project), alert: "Something went wrong. Please try again."
        end
    end

    def create
        if current_user.project.present?
            redirect_to my_projects_path,
                alert: "You can only have one project. Please edit your existing project instead."
            return
        end

        @project = current_user.build_project(project_params)

        if @project.save
            redirect_to project_path(@project), notice: "Project was successfully created."
        else
            flash.now[:alert] = "Could not create project. Please check the form for errors."
            render :index, status: :unprocessable_entity
        end
    end

    def my_projects
        @project = current_user.project
        if @project.nil?
            @projects = []
            @show_create_project = true
            render :index
        else
            redirect_to project_path(@project)
        end
    end

    def activity
        @followed_projects = current_user.followed_projects.includes(:user)
        @recent_updates = Update.includes(:project, :user)
                              .where(project_id: @followed_projects.pluck(:id))
                              .order(created_at: :desc)
                              .limit(30)
    end

    # Gotta say I love turbo frames and turbo streams and flashes in general
    def follow
        @project_follow = current_user.project_follows.build(project: @project)

        respond_to do |format|
            if @project_follow.save
                format.html { redirect_to request.referer || projects_path, notice: "You are now following this project!" }
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
                error_message = @project_follow.errors.full_messages.join(", ")
                format.html { redirect_to request.referer || projects_path, alert: "Could not follow project: #{error_message}" }
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
                format.html { redirect_to request.referer || projects_path, notice: "You have unfollowed this project." }
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
                format.html { redirect_to request.referer || projects_path, alert: "Could not unfollow project." }
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
        params.require(:project).permit(:title, :description, :readme_link, :demo_link, :repo_link, :banner, :category)
    end
end
