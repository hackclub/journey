class SessionsController < ApplicationController
    def create
      auth = request.env["omniauth.auth"]

      begin
        user = User.find_or_create(auth)
        session[:user_id] = user.id
        redirect_to dashboard_path, notice: "Signed in successfully!"
      rescue => e
        Rails.logger.error "Error during sign in: #{e.message}"
        redirect_to root_path, alert: "Error during sign in"
      end
    end

    def failure
      redirect_to root_path, alert: "Authentication failed."
    end

    def destroy
      session[:user_id] = nil
      redirect_to root_path, notice: "Signed out successfully!"
    end
end
