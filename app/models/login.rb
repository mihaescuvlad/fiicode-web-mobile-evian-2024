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

  def self.authenticate(email, password)
    return nil unless email && password

    login = self.where(email: email.downcase.strip).first
    return nil unless login && Password.check(password, login.password)

    login
  end
end