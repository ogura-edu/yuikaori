class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  
  def after_sign_in_path_for(resource)
    root_path
  end
  
  private
  def sign_in_required
    redirect_to new_user_session_url unless user_signed_in?
  end
  
  def approved_user!
    redirect_to root_path, alert: '承認ユーザ用ページになります。\n承認希望の場合は管理者(@justice_vsbr)に連絡してください' unless current_user.approved?
  end
  
  def admin_user!
    redirect_to root_path, alert: '管理画面です\n一般ユーザは入れません' unless current_user.admin?
  end
end
