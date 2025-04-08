class UpdatesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_project
    before_action :set_update, only: [ :destroy ]
    before_action :authorize_project_owner, only: [ :create, :destroy ]

    def create
        @update = @project.updates.build(update_params)
        @update.user = current_user

        respond_to do |format|
            if @update.save
                format.html { redirect_to project_path(@project), notice: "Update posted successfully!" }
                format.turbo_stream { 
                    flash[:notice] = "Update posted successfully!"
                    redirect_to project_path(@project)
                }
            else
                format.html { redirect_to project_path(@project), alert: "Failed to post update: #{@update.errors.full_messages.join(', ')}" }
                format.turbo_stream { 
                    flash[:alert] = "Failed to post update: #{@update.errors.full_messages.join(', ')}"
                    redirect_to project_path(@project)
                }
            end
        end
    end

    def destroy
        respond_to do |format|
            if @update.destroy
                format.html { redirect_to project_path(@project), notice: "Update deleted successfully!" }
                format.turbo_stream { 
                    flash[:notice] = "Update deleted successfully!"
                    redirect_to project_path(@project)
                }
            else
                format.html { redirect_to project_path(@project), alert: "Failed to delete update." }
                format.turbo_stream { 
                    flash[:alert] = "Failed to delete update."
                    redirect_to project_path(@project)
                }
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

    def authorize_project_owner
        unless current_user == @project.user
            redirect_to project_path(@project), alert: "You are not authorized to perform this action."
        end
    end

    def update_params
        params.require(:update).permit(:text, :attachment)
    end
end
