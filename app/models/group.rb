class Group < ActiveRecord::Base
  has_many :group_users
  has_many :users, through: :group_users
  has_many :payments

  def as_json(options={})
    super include: :users
  end
end
