class UsersController < ApplicationController
  def index
    redirect_back fallback_location: toppage_path, alert: '管理画面です 一般ユーザはは入れません' unless current_user.admin?
    @users = User.all
  end
  
  def approve
    puts '工事中'
    redirect_back fallback_location: toppage_path, alert: '管理画面です 一般ユーザはは入れません' unless current_user.admin?
  end
end
