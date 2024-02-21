require 'digest/sha2'

module Password
    def self.update(password)
        salt = self.salt
        self.store(hash(password, salt), salt)
    end

    def self.check(password, store)
        return false unless password && store
        hash = get_hash(store)
        salt = get_salt(store)
        self.hash(password, salt) == hash
    end

    protected

    def self.salt
        salt = ''
        64.times { salt << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61))).chr }
        salt
    end

    def self.hash(password, salt)
        Digest::SHA512.hexdigest("#{password}:#{salt}")
    end

    def self.store(hash, salt)
        hash + salt
    end

    def self.get_hash(store)
        store[0..127]
    end

    def self.get_salt(store)
        store[128..192]
    end
end