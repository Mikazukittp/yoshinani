class Participant < ActiveRecord::Base
  belongs_to :payment
  belongs_to :user

  validates :payment_id, presence: true
  validates :user_id, presence: true
end
