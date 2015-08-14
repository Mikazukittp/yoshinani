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

end
