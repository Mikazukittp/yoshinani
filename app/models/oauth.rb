class Oauth < ActiveRecord::Base
  validates :name, presence: true
end
