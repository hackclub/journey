class LandingController < ApplicationController
  def index
    redirect_to my_projects_path if user_signed_in?
  end
end
