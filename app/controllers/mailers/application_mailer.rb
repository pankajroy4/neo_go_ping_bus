class Mailers::ApplicationMailer < ActionMailer::Base
  default from: "admin@gmail.com"
  layout "mailer"
end
