class LandingController < ApplicationController
  def index
    redirect_to explore_path if user_signed_in?
  end
end
