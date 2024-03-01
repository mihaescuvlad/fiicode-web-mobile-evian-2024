class Admin < BaseLogin
  def self.authenticate(username, password)
    return nil unless username && password

    admin = self.where(username: username.strip).first
    return nil unless admin && Password.check(password, admin.password)

    admin
  end
end