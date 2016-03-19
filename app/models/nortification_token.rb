class NortificationToken < ActiveRecord::Base
  extend Enumerize

  belongs_to :user

  enumerize :device_type, in: %w(ios android)

  validates :device_token, uniqueness: true, presence: true
  validates :device_type, presence: true
end