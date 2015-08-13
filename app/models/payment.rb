class Payment < ActiveRecord::Base
  belongs_to :paid_user, class_name: 'User'
  belongs_to :group

  has_many :participant_reference, class_name: 'Participant'
  has_many :participants, class_name: 'User', through: :participant_reference, source: :user
end
