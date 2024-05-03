class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :confirmable
  validates :name, presence: true
  validates :registration_no, presence: true, if: :bus_owner?
  validates :registration_no, presence: true, uniqueness: true, if: :bus_owner?

  has_many :reservations, dependent: :destroy
  has_many :buses, dependent: :destroy
  has_one_attached :ticket_pdf
  has_one_attached :profile_pic

  # has_many :buses, -> { where(role: 'bus_owner') }, dependent: :destroy

  enum role: { admin: 0, bus_owner: 1, user: 2 }
  scope :admin, -> { where(role: "admin") }
  scope :user, -> { where(role: "user") }
  scope :bus_owner, -> { where(role: "bus_owner") }

  def generate_otp
    plain_text_otp = "%06d" % rand(10 ** 6)
    self.otp = BCrypt::Password.create(plain_text_otp)
    self.otp_sent_at = Time.now
    plain_text_otp
  end

  def valid_otp?(otp)
    return false if otp.blank? || otp_sent_at.nil?
    otp_age = Time.now - otp_sent_at
    return false if otp_age > 5.minutes
    BCrypt::Password.new(self.otp) == otp
  end

  def send_confirmation_instructions
    otp = generate_otp
    self.save!
    # ConfirmationInstructionsJob.set(wait: 1.seconds).perform_later(self, confirmation_token, otp) #when job defined
    Users::Mailer.confirmation_instructions(self, confirmation_token, otp).deliver_later(wait: 1.seconds)
    # Users::Mailer.confirmation_instructions(self, confirmation_token, otp).deliver_now #for inline
  end

  def send_reset_password_instructions
    token = set_reset_password_token
    # ResetPasswordInstructionsJob.set(wait: 1.seconds).perform_later(self, token) #when jon defined
    Users::Mailer.reset_password_instructions(self, token).deliver_later(wait: 1.seconds)
    # Users::Mailer.reset_password_instructions(self, token).deliver_now #for inline
    token
  end

  def send_devise_notification(notification, *args)
    # PasswordChangeJob.set(wait: 1.seconds).perform_later(self) #when jon defined
    Users::Mailer.password_change(self).deliver_later(wait: 1.seconds)
    # Users::Mailer.password_change(self).deliver_now #for inline
  end

  def send_email_changed_notification
    # EmailChangedJob.set(wait: 1.seconds).perform_later(self) #whenjob defined 
    Users::Mailer.email_changed(self).deliver_later(wait: 1.seconds)
    # Users::Mailer.email_changed(self).deliver_now #for inline
  end

  # def send_unlock_instructions
  #   raw, enc = Devise.token_generator.generate(self.class, :unlock_token)
  #   self.unlock_token = enc
  #   save(validate: false)
  #   # UnlockInstructionsJob.set(wait: 1.seconds).perform_later(self, enc) 
  #   Users::Mailer.unlock_instructions(self, enc).deliver_later(wait: 1.seconds)
  #   Users::Mailer.unlock_instructions(self, enc).deliver_now
  # end

  def generate_and_send_otp
    otp = generate_otp
    self.save!
    puts "========================  #{otp}  ========================="
    # OtpVerificationJob.set(wait: 1.seconds).perform_later(self, otp) #when jon defined
    Users::Mailer.otp_verification(self, otp).deliver_later(wait: 2.seconds)
    # Users::Mailer.otp_verification(self, otp).deliver_now # for inline
  end
end
