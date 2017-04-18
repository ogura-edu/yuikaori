class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Devise::Controllers::Rememberable
  
  def twitter
    user = User.find_for_oauth(request.env['omniauth.auth'])
    
    remember_me(user)
    
    sign_in_and_redirect user
  end
end
