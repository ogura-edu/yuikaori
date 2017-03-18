class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    @user = User.find_for_oauth(request.env['omniauth.auth'])
    
    # 登録済ならログイン、未登録なら新規登録画面へ
    if @user.persisted?
      sign_in_and_redirect @user
    else
      session["devise.#{provider}_data"] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end
end
