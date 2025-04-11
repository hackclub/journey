class ErrorsController < ApplicationController
  layout 'error'

  def not_found
    render 'shared/404', status: :not_found
  end

  def internal_server_error
    render 'shared/500', status: :internal_server_error
  end

  def unprocessable_entity
    render 'shared/422', status: :unprocessable_entity
  end

  def bad_request
    render 'shared/400', status: :bad_request
  end
end 