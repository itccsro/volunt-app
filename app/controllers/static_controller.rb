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
    user = User.find_by(email: email)
    if user
      begin
        UserMailer.reset_password(user).deliver_now
      rescue Exception=>x
        Rails.logger.error("contacts_signup: reset_password: #{x.class.name}: #{x.message}")
      end
    else
      user = User.create(email: email)
      begin
        UserMailer.welcome(user).deliver_now
      rescue Exception=>x
        Rails.logger.error("contacts_signup: welcome: #{x.class.name}: #{x.message}")
      end
    end

    profile = Profile.for_email(email)
    if !profile
      profile = Profile.new flags: Profile::PROFILE_FLAG_VOLUNTEER
    end
    
    #Parse the params for 123contactform field
    # 'controlnameXXX_YY' matches 'controlvalueXXX_YYY'
    # if value is 'yes' we assume is a checkbox
    # and we taggify the name
    tags = ''
    skills = ''
    params.each do |k, v|
      # Search for marcked checkboxes. Value should be "yes"
      if v == 'yes'
        # Validate that the key is "controlvalueXXX_YY"
        m = /controlvalue([\d\_]+)/.match(k)
        if m
          # if matched, m[1] captured the XXX_YY part
          # Look for its corresponding 'controlvalueXXX_YY'
          choice = params["controlname#{m[1]}"]
          if choice
            # The control name is "category - option". 
            # Remove everything before first -
            mc = /\A(.*?)\s*-\s*(.*)/.match(choice)
            # if there is no - the control is ignored
            if mc
              # category is captured in mc[1]
              # Everything after - is captured in mc[2]
              tagval = mc[2]
              # check if there is a ' - ', ignore everything after it
              mt = /(.+)(\s-\s)/.match(tagval)
              tagval = mt[1] if mt
              # Some controls (Terms & Conditions) also match
              # all conditions up to here, so we remove them based on complexity:
              # no more than 5 words (4 spaces)

              # by convention categories ending with ':' are considered 'Skills'
              # 123contacts form must respect this convention
              if mc[1].ends_with?(':')
                skills += ',' + tagval if tagval.count(' ') < 4
              else
                tags += ',' + tagval if tagval.count(' ') < 4
              end
            end
          end
        end
      end
    end

    ht = {
      full_name: "#{params["last_name"]} #{params["first_name"]}",
      nick_name: params["first_name"],
      email: params["email"],
      contacts: {phone: params["phone"]},
      location: "#{params["city"]}, #{params["country"]}",
      description: params["description"],
      hidden_tags: [
          'NEW PROFILE',
          'FOR REVIEW',
          'CIVICTECH',
          Date.today.to_s,
          "UID:#{params["uid"]}",
          "FID:#{params["fid"]}",
          "EID:#{params["entry_id"]}"],
      tags_string: tags,
      skills_string: skills
      }
    profile.update(ht)
    profile.save
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
    if (user && user.is_password_match?(@login_presenter.password))
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
