class Users::AdminController < ApplicationController
  before_action :admin_user!
  
  def index
    redirect_back fallback_location: root_path, alert: '管理画面です 一般ユーザはは入れません' unless current_user.admin?
    @users = User.all
  end
  
  def approve
    redirect_back fallback_location: root_path, alert: '管理画面です 一般ユーザはは入れません' unless current_user.admin?
  end
    User.find(params[:id]).update_attribute :approved, true
end
