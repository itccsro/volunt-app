class RedirectController < ApplicationController
  include LoginConcern
  authorization_required USER_LEVEL_NEWUSER, only: [:me]

  # GET /me
  def me
    profile = Profile.for_email(current_user_email)
    if profile.nil?
      logout_user
      redirect_to root_path
    elsif profile.is_coordinator?
      redirect_to coordinator_path(profile)
    elsif profile.is_fellow?
      redirect_to fellow_path(profile)
    elsif profile.is_volunteer?
      redirect_to volunteer_path(profile)
    else
      logout_user
      redirect_to root_path
    end
  end
end
