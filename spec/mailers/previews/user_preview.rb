# Preview all emails at http://localhost:3000/rails/mailers/user
class UserPreview < ActionMailer::Preview

  def welcome
    user = User.first
    UserMailer.welcome(user, {})
  end
  
  def reset_password
    user = User.first
    UserMailer.reset_password(user)
  end

end

