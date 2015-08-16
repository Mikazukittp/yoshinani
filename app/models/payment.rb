class Payment < ActiveRecord::Base
  belongs_to :paid_user, class_name: 'User'
  belongs_to :group

  has_many :participant_reference, class_name: 'Participant'
  has_many :participants, class_name: 'User', through: :participant_reference, source: :user

  # validation
  VALID_EMAIL_REGEX =  /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to:0 }
  validates :event, presence: true, unless: :is_repayment
  validates :description, presence: true, unless: :is_repayment
  validates :date, presence: true
  validates :group_id, presence: true
  validates :paid_user_id, presence: true, user_id: true, group_member: true

  def as_json(options={})
    super methods: [:paid_user, :participants]
  end

end
