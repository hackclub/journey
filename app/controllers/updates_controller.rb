class UpdatesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_project, only: [ :create, :destroy ]
    before_action :set_update, only: [ :destroy ]

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
        @update = @project.updates.build(update_params.merge(user: current_user))

        respond_to do |format|
            if @update.save
                format.html { redirect_to project_path(@project), notice: "Update was successfully created." }
                format.turbo_stream
            else
                format.html { redirect_to project_path(@project), alert: "Could not create update." }
                format.turbo_stream { render turbo_stream: turbo_stream.replace("new_update", partial: "updates/form", locals: { update: @update }) }
            end
        end
    end

    def destroy
        if @update.user == current_user
            @update.destroy
            respond_to do |format|
                format.html { redirect_to project_path(@project), notice: "Update was successfully deleted." }
                format.turbo_stream
            end
        else
            respond_to do |format|
                format.html { redirect_to project_path(@project), alert: "You can only delete your own updates." }
                format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-container", partial: "shared/flash") }
            end
        end
    end

    private

    def set_project
        @project = Project.find(params[:project_id])
    end

    def set_update
        @update = @project.updates.find(params[:id])
    end

    def update_params
        params.require(:update).permit(:text, :attachment)
    end
end
