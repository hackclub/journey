module Api
  module V1
    class UpdatesController < ApplicationController
      def index
        @updates = Update.all.map do |update|
          {
            text: update.text,
            attachment: update.attachment,
            project_id: update.project_id,
            slack_id: update.user.slack_id,
            created_at: update.created_at,
            updated_at: update.updated_at
          }
        end
        render json: @updates
      end

      def show
        @update = Update.find(params[:id])
        render json: {
          text: @update.text,
          attachment: @update.attachment,
          project_id: @update.project_id,
          slack_id: @update.user.slack_id,
          created_at: @update.created_at,
          updated_at: @update.updated_at
        }
      end
    end
  end
end 