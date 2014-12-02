class User < ActiveRecord::Base
  before_create :encrypt_password

  validates :email,    :presence =>true, :uniqueness=>true
  validates :name,     :presence =>true
  validates :profile,  :presence =>true
  validates :password, :presence =>true, :length => { :minimum => 5, :maximum => 40 }, :confirmation => true

  PROFILES = ["Sala 1", "Sala 2"]

  def self.md5(text)
    Digest::MD5.hexdigest(text)
  end

  def encrypt_password
    if password.present?
      self.password = Digest::MD5.hexdigest(self.password)
    end
  end

  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.password == md5(password)
      user
    end
  end

  def admin?
    self.role == 'admin'
  end

  private

  def generate_digest_token
    Digest::SHA1.hexdigest(SecureRandom.base64)
  end
end