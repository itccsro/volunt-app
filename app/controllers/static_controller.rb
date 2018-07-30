require 'net/http'

class StaticController < ApplicationController
  include LoginConcern
  include SslConfig
  force_ssl only: [:home,
      :signup,
      :signup_post,
      :login,
      :login_post,
      :password_reset,
      :httpsify], if: :ssl_configured?
  
  skip_before_action :verify_authenticity_token, only: [:contacts_signup]

  layout 'static'

  def httpsify
    begin
      url = URI.parse(params[:url])
      render text: Net::HTTP.get(url)
    rescue Exception => ex
      Rails.logger.error("httpsify: #{ex.class.name}: #{ex.message}")
      redirect_to params[:url]
    end
  end

  def home
    if is_user_logged_in?
      flash.keep(:notice)
      redirect_to me_path
    end
    @signup_presenter = SignupPresenter.new
  end

  def contacts_signup
    email = params["email"];
    user = User.find_or_create_by(email: email)
    begin
      UserMailer.welcome(user, params.to_hash).deliver_now
    rescue Exception=>x
      Rails.logger.error("contacts_signup: welcome: #{x.class.name}: #{x.message}")
    end
  end

  def login
    logout_user
    @login_presenter = LoginPresenter.new
  end

  def login_post
    @login_presenter = LoginPresenter.new params.fetch(:login_presenter, {}).permit(:email, :password)
    user = nil
    if (@login_presenter.valid?)
      user = User.where(email: @login_presenter.email).first
    end
    if (verify_recaptcha(model: @login_presenter) && user && user.is_password_match?(@login_presenter.password))
      login_user(user)
      redirect_to root_path
    else
      @login_presenter.errors.add(:email, :invalid, message: 'Invalid user name or password')
      render :login
    end
  end

  def logout
    logout_user
    redirect_to root_path
  end

  def impersonate
    notice = 'Not found'
    if Rails.env.development?
      p = Profile.for_email(params[:email])
      if p
        logout_user
        user = User.find_or_create_by(email: params[:email])
        login_user(user)
        notice = "You have impersonated user: #{user.id}: #{user.email}: at level: #{current_user_level}"
      end
    end
    redirect_to root_path, notice: notice
  end
end
