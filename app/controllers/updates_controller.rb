class UpdatesController < ApplicationController
    include ActionView::RecordIdentifier
    before_action :authenticate_user!
    before_action :set_project, only: [ :create, :destroy, :update ]
    before_action :set_update, only: [ :destroy, :update ]
    before_action :check_if_shipped, only: [ :create, :destroy, :update ]
    skip_before_action :authenticate_user!, only: [ :api_create ]
    before_action :authenticate_api_key, only: [ :api_create ]
    skip_before_action :verify_authenticity_token, only: [ :api_create ]
    def index
        @page = [ params[:page].to_i, 1 ].max
        @per_page = 10

        @updates = Update.includes(:project, :user)
                        .where(project_id: current_user.followed_projects.pluck(:id))
                        .order(created_at: :desc)
                        .offset((@page - 1) * @per_page)
                        .limit(@per_page)

        respond_to do |format|
            format.turbo_stream
        end
    end

    def create
        @project = Project.find(params[:project_id])

        if @project.hackatime_keys.present? && current_user.has_hackatime? && params[:update][:timer_session_id].blank?
            current_user.refresh_hackatime_data_now
        end

        # Skip time verification if user is linking a timer session
        if params[:update][:timer_session_id].blank? &&
           @project.hackatime_keys.present? && current_user.has_hackatime? &&
           current_user.hackatime_stat.present? &&
           !current_user.hackatime_stat.has_enough_time_since_last_update?(@project)
            seconds_needed = current_user.hackatime_stat.seconds_needed_since_last_update(@project)
            redirect_to project_path(@project), alert: "You need to spend more time on this project before posting an update. #{helpers.format_seconds(seconds_needed)} more needed since your last update."
            return
        end

        if ENV["UPDATES_STATUS"] == "locked"
            redirect_to @project, alert: "Posting updates is currently locked. Please check back later when updates are unlocked."
            return
        end

        @update = @project.updates.build(update_params)
        @update.user = current_user

        if @project.hackatime_keys.present? && @project.user.has_hackatime? && params[:update][:timer_session_id].blank?
            @update.last_hackatime_time = @project.hackatime_total_time
        end

        if @update.save
            redirect_to @update.project, notice: "Update was successfully posted."
        else
            redirect_to @update.project, alert: "Failed to post update."
        end
    end

    def destroy
        if @update.user == current_user
            @update.destroy
            redirect_to @update.project, notice: "Update was successfully deleted."
        else
            redirect_to @update.project, alert: "You can only delete your own updates."
        end
    end

    def update
        if @update.user != current_user
            flash.now[:alert] = "You can only edit your own updates."
            redirect_to @update.project, alert: "You can only edit your own updates."
            return
        end

        # Only allow editing the text field
        if @update.update(update_params.slice(:text))
            redirect_to @update.project, notice: "Update was successfully edited."
        else
            redirect_to @update.project, alert: "Failed to edit update."
        end
    end

    def api_create
        if ENV["UPDATES_STATUS"] == "locked"
            return render json: { error: "Posting updates is currently locked" }, status: :forbidden
        end

        user = User.find_by(slack_id: params[:slack_id])
        return render json: { error: "User not found" }, status: :not_found unless user

        project = Project.find_by(id: params[:project_id])
        return render json: { error: "Project not found" }, status: :not_found unless project

        update = project.updates.build(update_params)
        update.user = user

        if update.save
            render json: { message: "Update successfully created", update: update }, status: :created
        else
            render json: { error: "Failed to create update", details: update.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def set_project
        @project = Project.find(params[:project_id])
    end

    def set_update
        @update = @project.updates.find(params[:id])
    end

    def check_if_shipped
        if @project.is_shipped?
            redirect_to @project, alert: "This project has been shipped and cannot be modified."
        end
    end

    def authenticate_api_key
        api_key = request.headers["Authorization"]
        unless api_key.present? && api_key == ENV["API_KEY"]
            render json: { error: "Unauthorized" }, status: :unauthorized
        end
    end

    def update_params
        params.require(:update).permit(:text, :attachment, :timer_session_id)
    end
end
