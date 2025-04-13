class SessionsController < ApplicationController
    def create
      auth = request.env["omniauth.auth"]
      
      Rails.logger.tagged("Authentication") do
        Rails.logger.info({
          event: "auth_attempt",
          slack_id: auth.info.authed_user.id,
          ip: request.remote_ip,
          user_agent: request.user_agent,
          request_id: request.request_id
        }.to_json)
      end

      begin
        user = User.find_or_create(auth)
        
        Rails.logger.tagged("Authentication") do
          Rails.logger.info({
            event: "auth_success",
            slack_id: auth.info.authed_user.id,
            user_id: user.id,
            email: user.email,
            request_id: request.request_id
          }.to_json)
        end
        
        session[:user_id] = user.id
        redirect_to my_projects_path, notice: "Signed in successfully!"
      rescue => e
        Rails.logger.error "Error during sign in: #{e.message}"
        redirect_to root_path, alert: e.message
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
