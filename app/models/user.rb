require 'digest/md5'

class User < ActiveRecord::Base
  VALID_EMAIL_REGEX =  /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_many :group_users
  has_many :groups, through: :group_users
  has_many :oauth_registrations
  has_many :notification_tokens

  has_many :totals
  has_many :paid_payments, class_name: 'Payment', foreign_key: :paid_user_id
  has_many :participants
  has_many :to_pay_payments, class_name: 'Payment', through: :participants, source: :payment

  # validation
  with_options unless: proc { [:oauth_registration].include?(validation_context) } do |user|
    user.validates :account,  presence: true
    user.validates :password, presence: true
  end

  validates :account,  uniqueness: true, length: {maximum: 30}
  validates :username, length: {maximum: 30}
  validates :email, uniqueness: true, allow_nil: true, length: {maximum: 256}, format: { with: VALID_EMAIL_REGEX, allow_blank: true }
  validates :password, length: {minimum: 7, maximum: 20, allow_blank: true}, on: [:create, :reset_password]
  validates :role, numericality: { only_integer: true }

  before_create :hash_password
  before_create :new_token

  def account=(value)
    write_attribute(:account, value.try!(:strip))
  end

  def as_json(options={})
    if options[:only].present?
      return super(except: [:password, :salt])
    end

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
    # Oauth認証の場合はpasswordがnilでsaveされる
    return if self.password.nil?

    self.salt = User.new_salt
    self.password = User.crypt_password(self.password.strip, self.salt)
  end

  # tokenの新規作成
  def new_token
    s = SecureRandom.base64(24)
    self.token = s[0, 32]
  end

  def set_reset_password_token
    update(reset_password_token: SecureRandom.base64(10), reset_password_at: Time.now)
  end

  def active_groups()
    groups.select{|group| exist_group_user_with_status(group, 'active') }.as_json(user_id: self.id)
  end

  def invited_groups()
    groups.select{|group| exist_group_user_with_status(group, 'inviting') }.as_json(user_id: self.id)
  end

  def exist_group_user_with_status(group, status)
    result = false

    group.group_users.each do |gu|
      if gu.user_id == self.id && gu.status == status
        result = true
      end
    end

    return result
  end

  def oauth_registration_and_no_attribute?
    oauth_registrations.present? && account.nil?
  end

  private

  def include_totals(group_id)
    group_id.present? ? totals.select{|t| t.group_id == group_id} : totals
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
