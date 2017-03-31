class TopPageController < ApplicationController
  before_action :sign_in_required, only: [:show]
  skip_before_action :authenticate_user!, only: [:index]
  
  def index
    if user_signed_in?
      redirect_to toppage_path
    end
  end

  def show
  end
end
