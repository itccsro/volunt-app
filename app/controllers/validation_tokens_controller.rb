require 'base64'

class ValidationTokensController < ApplicationController
  include ActiveSupport::Callbacks
  include LoginConcern
  include SslConfig

  force_ssl if: :ssl_configured?

  helper_method :reset_password_presenters_path
  before_action :find_token
  define_callbacks :confirm_user_email
  layout 'static'

  def show
    # Any link that is clicked is actually a valid user email confirmation
#    if !@token.user.nil?
#      User.transaction do
#        run_callbacks :confirm_user_email do
#          if !@token.user.is_email_confirmed?
#            @token.user.is_email_confirmed = true
#            @token.user.save!
#          end
#        end
#      end
#    end

    if @token.is_reset_password? or @token.is_123contacts?
      @reset_password_presenter = ResetPasswordPresenter.new
      render :reset_password
    elsif @token.is_confirm_email?
      render :confirm_email
    elsif @token.is_invitation?
      render :confirm_invitation
    end
  end

  def update
    if @token.is_reset_password? or @token.is_123contacts?
      @reset_password_presenter = ResetPasswordPresenter.new reset_password_params
      if @reset_password_presenter.invalid?
        render :reset_password, status: :conflict
      else
        user = @token.user
        user.password = @reset_password_presenter.password
        user.password_confirmation = @reset_password_presenter.password_confirmation
        if user.save
          notice = "Parola pentru #{user.email} a fost schimbata"
          if @token.is_123contacts?
            create_or_update_profile
            notice += " si profilul a fost modificat cu datele introduse in formularul civictech.ro"
          end
          login_user(user)
          redirect_to me_path, notice: notice
        else
          @reset_password_presenter.errors << user.errors
          render :reset_password, status: :conflict
        end
      end
    else
      render :unknown, status: :conflict
    end

  end

  def reset_password_presenters_path
    validation_token_path(@token)
  end

  private

  def create_or_update_profile
    params = @token.params
    email = params["email"]

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
                skills += tagval + ', ' if tagval.count(' ') < 4
              else
                tags += tagval + ', ' if tagval.count(' ') < 4
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
    if profile.flags < Profile::PROFILE_FLAG_VOLUNTEER
      ht[:flags] = Profile::PROFILE_FLAG_VOLUNTEER
    end
    profile.update(ht)
    profile.save
  end

  def reset_password_params
    params.fetch(:reset_password_presenter, {}).permit(
      :password,
      :password_confirmation)
  end

  def find_token
    @token = ValidationToken.find_token(params[:id])
    if @token.nil?
      render :unknown, status: :not_found
    end
  end

end
