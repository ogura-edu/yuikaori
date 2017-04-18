class Users::AdminController < ApplicationController
  before_action :admin_user!
  before_action :set_user, except: :index
  
  def index
    @users = User.where('id > 1')
  end
  
  def approve
    if @user.approved?
      @user.update_attribute :approved, false
    else
      @user.update_attribute :approved, true
    end
    redirect_back fallback_location: root_path
  end
  
  def admin
    if @user.admin?
      @user.update_attribute :admin, false
    else
      @user.update_attribute :admin, true
    end
    redirect_back fallback_location: root_path
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
end
