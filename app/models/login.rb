class Login < BaseLogin
  field :email, type: String
  has_one :user

  validates_uniqueness_of :email, case_sensitive: false
  validates_presence_of :email, :user

  def initialize(attrs = {})
    attrs.include?(:email) or raise ArgumentError

    super
    self.email = attrs[:email]
  end

  def email=(email)
    write_attribute(:email, email.downcase.strip)
  end

  def self.authenticate_by_email(email, password)
    login = Login.find_by(email: email.downcase.strip) rescue nil
    return nil unless login.present?

    self.authenticate(login.username, password)
  end
end