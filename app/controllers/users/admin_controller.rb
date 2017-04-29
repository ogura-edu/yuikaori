class Users::AdminController < ApplicationController
  before_action :admin_user!
  before_action :set_user, except: :index
  
  def index
    @users = User.where('id > 1')
  end
  
  def approve
    if @user.approved?
      @user.update(approved: false)
    else
      @user.update(approved: true)
    end
    redirect_back fallback_location: root_path
  end
  
  def admin
    if @user.admin?
      @user.update(admin: false)
    else
      @user.update(admin: true)
    end
    redirect_back fallback_location: root_path
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
end
