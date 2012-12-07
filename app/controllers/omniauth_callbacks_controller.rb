class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authenticate_user!

  def github
    @user = User.find_for_github_oauth(request.env["omniauth.auth"], current_user)
    sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
    set_flash_message(:notice, :success, :kind => "Github") if is_navigational_format?
  end
end