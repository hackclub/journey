class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_update

  def create
    @comment = @update.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      current_user.update(has_commented: true) unless current_user.has_commented
      redirect_to @update.project, notice: "Comment was successfully created."
    else
      redirect_to @update.project, alert: "Failed to add comment."
    end
  end

  def destroy
    @comment = @update.comments.find(params[:id])

    if @comment.destroy
      redirect_to @update.project, notice: "Comment deleted successfully!"
    else
      redirect_to @update.project, alert: "Failed to delete comment."
    end
  end

  private

  def set_update
    @update = Update.find(params[:update_id])
  end

  def comment_params
    params.require(:comment).permit(:text)
  end
end
