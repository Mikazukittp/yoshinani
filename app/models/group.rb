class Group < ActiveRecord::Base
  has_many :group_users
  has_many :users, through: :group_users
  has_many :payments

  def as_json(options={})
    super methods: :include_users
  end

  def include_users
    users.as_json(group_id: self.id)
  end
end
