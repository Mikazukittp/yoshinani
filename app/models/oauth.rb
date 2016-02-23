class Oauth < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true
  validates :name, presence: true
  validates :auth_id, presence: true

end
