class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  
  def after_sign_in_path_for(resource)
    toppage_path
  end
  
  private
  def sign_in_required
    redirect_to new_user_session_url unless user_signed_in?
  end
end
