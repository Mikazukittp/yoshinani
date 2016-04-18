class OauthRegistration < ActiveRecord::Base
  belongs_to :user
  belongs_to :oauth

  validates :user_id,  presence: true, uniqueness: {scope: :oauth_id}
  validates :oauth_id, presence: true
  validates :third_party_id,  presence: true

end
