class Login < BaseLogin
  field :email, type: String
  field :confirm_email_key, type: String
  has_one :user

  validates_uniqueness_of :email, case_sensitive: false
  validates_presence_of :email, :user

  def initialize(attrs = {})
    attrs.include?(:email) or raise ArgumentError

    super
    write_attribute(:confirm_email_key, SecureRandom.urlsafe_base64(32))
    self.email = attrs[:email]
  end

  def email=(email)
    write_attribute(:email, email.downcase.strip)
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

  def confirm_email_key=(_)
    raise NoMethodError
  end

  def confirm_email_key
    return nil if confirmed_email?
    read_attribute(:confirm_email_key)
  end

  def confirmed_email?
    read_attribute(:confirm_email_key) == ""
  end

  def confirm_email
    write_attribute(:confirm_email_key, "")
  end
end