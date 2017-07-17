class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password.subject
  #
  def reset_password(user, email = nil)
    validation = ValidationToken.reset_password user
    @url = validation_token_url(validation)
    @user = user
    @to = email || @user.email
    mail(to: @to, subject: 'Resetează parola de voluntar civictechᴿᴼ')
  end

  def welcome(user, params)
    validation = ValidationToken.confirm_123contacts user, params
    @url = validation_token_url(validation)
    @user = user
    @to = @user.email
    mail(to: @user.email, subject: 'Bine ai venit în comunitatea civictechᴿᴼ')
  end
end
