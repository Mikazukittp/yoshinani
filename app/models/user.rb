require 'digest/md5'
class User < ActiveRecord::Base
  has_many :group_users
  has_many :groups, through: :group_users

  has_many :totals
  has_many :paid_payments, class_name: 'Payment', foreign_key: :paid_user_id
  has_many :participants
  has_many :to_pay_payments, class_name: 'Payment', through: :participants, source: :payment

  # validation
  VALID_EMAIL_REGEX =  /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :account, presence: true, uniqueness: true
  validates :username, presence: true
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  validates :password, presence: true
  validates :role, numericality: { only_integer: true }

  before_create :hash_password
  before_create :new_token

  def as_json(options={})
    # Groupの子として表示する際は無限Loopにならないように、Groupsを表示しない
    methods = options[:group_id].present? ? [] : %i(active_groups invited_groups)

    super(except: [:password, :salt], methods: methods).tap do |json|
      json[:totals] = include_totals(options[:group_id].presence)
    end
  end

  # 認証を行う
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
    self.token = s[0, 32]
  end

  def active_groups()
    groups.includes(:group_users).where(group_users: {status: 'active'}).as_json(user_id: self.id)
  end

  def invited_groups()
    groups.includes(:group_users).where(group_users: {status: 'inviting'}).as_json(user_id: self.id)
  end

  private

  def include_totals(group_id)
    group_id.present? ? totals.where(group_id: group_id) : totals
  end


  # パスワードを暗号化する
  def self.crypt_password(password, salt)
    Digest::MD5.hexdigest(password + salt)
  end

  # パスワード暗号化のためのsalt生成
  def self.new_salt
    # s = rand.to_s.tr('+', '.')
    s = SecureRandom.base64(24)
    s[0, 32]
  end
end
