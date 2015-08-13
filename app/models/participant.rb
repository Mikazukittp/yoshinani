class Participant < ActiveRecord::Base
  belongs_to :payment
  belongs_to :group
  belongs_to :user
end
