class TopPageController < ApplicationController
  before_action :sign_in_required, only: [:show]
  
  def index
    if user_signed_in?
      redirect_to toppage_path
    end
  end

  def show
  end
end
