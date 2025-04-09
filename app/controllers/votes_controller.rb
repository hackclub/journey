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
                format.html { redirect_to new_vote_path, notice: "Vote Submitted!" }
                format.turbo_stream {
                    flash[:notice] = "Vote Submitted!"
                    redirect_to new_vote_path
                }
            else
                format.html {
                    flash.now[:alert] = "Failed to submit vote: #{@vote.errors.full_messages.join(', ')}"
                    render :new, status: :unprocessable_entity
                }
                format.turbo_stream {
                    flash.now[:alert] = "Failed to submit vote: #{@vote.errors.full_messages.join(', ')}"
                    render :new, status: :unprocessable_entity
                }
            end
        end
    end

    private

    def set_projects
        voted_project_ids = current_user.votes.pluck(:project_id)
        @projects = Project.where.not(id: voted_project_ids).order("RANDOM()").limit(2)

        if @projects.size < 2
            redirect_to root_path, alert: "Not enough projects available for voting. Check back later!"
        end
    end

    def vote_params
        params.require(:vote).permit(:project_id, :explanation)
    end
end
