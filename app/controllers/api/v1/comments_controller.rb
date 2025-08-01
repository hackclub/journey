module Api
  module V1
    class CommentsController < ApplicationController
      def index
        @comments = Comment.all.map do |comment|
          {
            text: comment.text,
            update_id: comment.update_id,
            slack_id: comment.user.slack_id,
            created_at: comment.created_at
          }
        end
        render json: @comments
      end

      def show
        @comment = Comment.find(params[:id])
        render json: {
          text: @comment.text,
          update_id: @comment.update_id,
          slack_id: @comment.user.slack_id,
          created_at: @comment.created_at
        }
      end
    end
  end
end
