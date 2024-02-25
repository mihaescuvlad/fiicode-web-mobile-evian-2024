class Login
    include Mongoid::Document
    include Mongoid::Timestamps
    include ActiveModel::SecurePassword

    field :email, type: String
    field :username, type: String
    field :account_id, type: BSON::ObjectId
    field :email_uc, type: String, default: -> { email.upcase.strip if email.present? }
    field :password, type: String
    field :user_id, type: BSON::ObjectId
    
    before_create :strip_email

    validates_uniqueness_of :email, :username, case_sensitive: false
    validates_presence_of :email, :password


    def set_password(password)
        hashed_password = Password.update(password)
        update_attributes!(password: hashed_password)
    end

    def strip_email
        self.email = self.email.strip
        self.email_uc = self.email_uc.strip
    end

    def self.authenticate(email, password)
        return nil unless email && password

        login = Login.where(email_uc: email.upcase.strip).first
        return nil unless login && Password.check(password, login.password)
        
        login.password = nil
        login
    end
end