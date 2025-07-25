class VotesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_projects, only: [ :new, :create ]

    def new
        @vote = Vote.new
        @user_vote_count = current_user.votes.count

        session[:vote_tokens] = {}

        @projects.each do |project|
            token = SecureRandom.hex(16)
            session[:vote_tokens][token] = {
                "project_id" => project.id,
                "user_id" => current_user.id,
                "expires_at" => 2.hours.from_now.iso8601
            }
        end
    end

    def create
        token = params[:vote_token]
        token_data = session[:vote_tokens]&.[](token)

        @vote = current_user.votes.build(vote_params)

        if @projects.size == 2
            @vote.loser_id = @projects.find { |p| p.id != @vote.winner_id }.id
        end

        unless @vote.authorized_with_token?(token_data)
            redirect_to new_vote_path, alert: "Vote validation failed"
            return
        end

        if @vote.save
            session[:vote_tokens].delete(token)

            redirect_to new_vote_path, notice: "Vote Submitted!"
        else
             redirect_to new_vote_path, alert: @vote.errors.full_messages.join(", ")
        end
    end

    private

    def set_projects
        voted_winner_ids = current_user.votes.pluck(:winner_id)
        voted_loser_ids = current_user.votes.pluck(:loser_id)
        voted_project_ids = voted_winner_ids + voted_loser_ids

        @projects = Project.where(is_shipped: true)
                          .where.not(id: voted_project_ids)
                          .where.not(user_id: current_user.id)
                          .where.not(demo_link: [ nil, "" ])
                          .order("RANDOM()")
                          .limit(2)
    end

    def vote_params
        params.require(:vote).permit(:winner_id, :explanation,
                                      :winner_demo_opened, :winner_readme_opened, :winner_repo_opened,
                                      :loser_demo_opened, :loser_readme_opened, :loser_repo_opened,
                                      :time_spent_voting_ms, :music_played)
    end
end
