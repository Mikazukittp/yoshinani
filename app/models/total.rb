class Total < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  validates :paid, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :to_pay, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, user_id: true, group_member: true

end
