class ApplicationMailer < ActionMailer::Base
  add_template_helper(EmailHelper)
  default from: 'membri@civictech.ro'
  layout 'mailer'
end
