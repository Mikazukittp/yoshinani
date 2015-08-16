require 'digest/md5'
class User < ActiveRecord::Base
  has_many :group_users
  has_many :groups, through: :group_users

  has_many :totals
  has_many :paid_payments, class_name: 'Payment', foreign_key: :paid_user_id
  has_many :participants
  has_many :to_pay_payments, class_name: 'Payment', through: :participants, source: :payment

  # soft_deletable

  # validation
  VALID_EMAIL_REGEX =  /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :account, presence: true, uniqueness: true
  validates :username, presence: true
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  validates :password, presence: true
  validates :role, numericality: { only_integer: true }

  before_create :hash

  def as_json(options={})
    super except: [:password, :salt], methods: :totals
  end

  # 認証を行う。
  def authoricate(password)
    User.crypt_password(password, self.salt) == self.password
  end

  # DB格納前のフック
  # saltと暗号化されたパスワードを生成
  def hash_password
    self.salt = User.new_salt
    self.password = User.crypt_password(self.password, self.salt)
  end

  # tokenの新規作成
  def new_token
    s = SecureRandom.base64(24)
    s[0, if s.size > 32 then 32 else s.size end]
    self.token = s
    s
  end

  private

  # パスワードを暗号化する
  def self.crypt_password(password, salt)
    Digest::MD5.hexdigest(password + salt)
  end

  # パスワード暗号化のためのsalt生成
  def self.new_salt
    # s = rand.to_s.tr('+', '.')
    s = SecureRandom.base64(24)
    s[0, if s.size > 32 then 32 else s.size end]
  end

end
