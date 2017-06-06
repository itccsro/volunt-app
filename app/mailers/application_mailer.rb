class ApplicationMailer < ActionMailer::Base
  add_template_helper(EmailHelper)
  default from: 'hello@civictech.ro'
  layout 'mailer'
end
