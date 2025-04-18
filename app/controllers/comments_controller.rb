class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_update

  def create
    @comment = @update.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      current_user.update(has_commented: true) unless current_user.has_commented
      respond_to do |format|
        redirect_to @update.project, notice: "Update was successfully created."
      end
    else
      flash.now[:alert] = "Failed to add comment."
      render turbo_stream: turbo_stream.replace("comment-form-#{@update.id}", 
        partial: "comments/form", 
        locals: { update: @update, comment: @comment })
    end
  end

  def destroy
    @comment = @update.comments.find(params[:id])
    
    if @comment.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @update.project, notice: "Comment deleted successfully!" }
      end
    else
      flash.now[:alert] = "Failed to delete comment."
      render turbo_stream: turbo_stream.replace("comment-#{@comment.id}", 
        partial: "comments/comment", 
        locals: { comment: @comment })
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