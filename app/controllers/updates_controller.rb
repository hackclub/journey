class UpdatesController < ApplicationController
    include ActionView::RecordIdentifier
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
        @update = @project.updates.build(update_params)
        @update.user = current_user

        if @update.save
            respond_to do |format|
                format.turbo_stream do
                    render turbo_stream: [
                        turbo_stream.prepend("updates", partial: "updates/update", locals: { update: @update }),
                        turbo_stream.replace("update-form", partial: "projects/update_form")
                    ]
                end
                format.html { redirect_to project_path(@project), notice: "Update was successfully posted." }
            end
        else
            respond_to do |format|
                format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-container", partial: "shared/flash") }
                format.html { redirect_to project_path(@project), alert: "Failed to post update." }
            end
        end
    end

    def destroy
        if @update.user == current_user
            @update.destroy
            flash.now[:notice] = "Update was successfully deleted."
            respond_to do |format|
                format.turbo_stream do
                    render turbo_stream: [
                        turbo_stream.remove(dom_id(@update)),
                        turbo_stream.replace("flash-container", partial: "shared/flash")
                    ]
                end
                format.html { redirect_to project_path(@project), notice: "Update was successfully deleted." }
            end
        else
            flash.now[:alert] = "You can only delete your own updates."
            respond_to do |format|
                format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-container", partial: "shared/flash") }
                format.html { redirect_to project_path(@project), alert: "You can only delete your own updates." }
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
