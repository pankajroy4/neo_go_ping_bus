
class ConfirmationInstructionsJob < ApplicationJob
#   queue_as :default

#   def perform(user, confirmation_token ,otp)
#     # Users::Mailer.approval_email(bus).deliver
#     Users::Mailer.confirmation_instructions(user, confirmation_token, otp).deliver
#   end
end
