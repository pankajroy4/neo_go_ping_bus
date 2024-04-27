class ResetPasswordInstructionsJob < ApplicationJob
#   queue_as :default

#   def perform(user, token)
#     @token = token
#     Users::Mailer.reset_password_instructions(user, @token).deliver
#   end
end
