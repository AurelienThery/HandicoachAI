class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard]

  def index
    redirect_to dashboard_path if user_signed_in?
  end

  def dashboard
    @routines = current_user.accessible_routines
    @recent_messages = current_user.chat_messages.recent.limit(5)
  end
end
