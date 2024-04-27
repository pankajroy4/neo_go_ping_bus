class Users::Mailer < Devise::Mailer
  include Rails.application.routes.url_helpers

  def confirmation_instructions(record, token, otp)
    @resource = record
    @token = token
    @otp = otp
    mail to: @resource.email, subject: "Confirmation instructions"
  end

  def otp_verification(record, otp)
    @user = record
    @otp = otp
    mail(to: @user.email, subject: "PINGBUS 🚌 login OTP")
  end

  def bus_approval(bus)
    @bus = bus
    if @bus.main_image.attached?
      attachments.inline["#{@bus.name}.jpg"] = @bus.main_image.download
    else
      attachments.inline["#{@bus.name}.jpg"] = File.read("app/assets/images/bus_logo2.png")
    end
    mail to: @bus.user.email, subject: "Bus approval Email!!" if bus.user.bus_owner?
  end
end
