class Login < BaseLogin
  field :email, type: String
  field :provider, type: String
  field :uid, type: String
  field :confirmed_username, type: Boolean, default: true
  has_one :user

  validates_uniqueness_of :email

  def initialize(attrs = {})
    attrs.include?(:email) or raise ArgumentError

    super
    write_attribute(:confirm_email_key, SecureRandom.urlsafe_base64(32))
    self.email = attrs[:email]
  end

  def email=(email)
    write_attribute(:email, email.downcase.strip)
  end

  def password=(password)
    super
    write_attribute(:reset_password_key, "")
  end

  def self.authenticate(username, password)
    login = super
    return nil unless login.present?

    raise ArgumentError, "Please confirm your account email." unless login.confirmed_email?
    login
  end

  def self.authenticate_by_email(email, password)
    login = Login.find_by(email: email.downcase.strip) rescue nil
    return nil unless login.present?

    self.authenticate(login.username, password)
  end

  def confirm_email_key
    return nil if confirmed_email?
    read_attribute(:confirm_email_key)
  end

  def confirmed_email?
    read_attribute(:confirm_email_key).blank?
  end

  def confirm_email
    write_attribute(:confirm_email_key, "")
  end

  def generate_reset_password_key
    write_attribute(:reset_password_key_expires_at, DateTime.current + 1.hour)
    write_attribute(:reset_password_key, SecureRandom.urlsafe_base64(32))
    reset_password_key
  end

  def reset_password_key
    return nil if read_attribute(:reset_password_key).blank?
    return nil if DateTime.current > read_attribute(:reset_password_key_expires_at)
    read_attribute(:reset_password_key)
  end
end