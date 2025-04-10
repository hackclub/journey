class VotesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_projects, only: [ :new, :create ]

    def new
        @vote = Vote.new
    end

    def create
        @vote = current_user.votes.build(vote_params)

        respond_to do |format|
            if @vote.save
                format.turbo_stream { 
                    flash.now[:notice] = "Vote Submitted!"
                    redirect_to new_vote_path
                }
                format.html { redirect_to new_vote_path, notice: "Vote Submitted!" }
            else
                format.turbo_stream { 
                    flash.now[:alert] = @vote.errors.full_messages.join(", ")
                    render turbo_stream: turbo_stream.update("vote_form_#{@vote.project_id}", 
                        partial: "votes/form", 
                        locals: { project: Project.find(@vote.project_id), vote: @vote })
                }
                format.html { 
                    flash.now[:alert] = @vote.errors.full_messages.join(", ")
                    render :new, status: :unprocessable_entity 
                }
            end
        end
    end

    private

    def set_projects
        voted_project_ids = current_user.votes.pluck(:project_id)
        projects_with_updates = Project.joins(:updates).distinct.pluck(:id)
        
        @projects = Project.where(id: projects_with_updates)
                          .where.not(id: voted_project_ids)
                          .order("RANDOM()")
                          .limit(2)
    end

    def vote_params
        params.require(:vote).permit(:project_id, :explanation)
    end
end
