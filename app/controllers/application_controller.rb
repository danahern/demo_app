class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  before_filter :mailer_set_url_options

  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  def github
    @github ||= Github.new
  end

  def authenticated_github
    if user_signed_in?
      @authenticated_github ||= Github.new(oauth_token: current_user.token)
    else
      nil
    end
  end
  helper_method :authenticated_github
end
