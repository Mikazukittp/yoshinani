class Group < ActiveRecord::Base
  has_many :group_users
  has_many :users, through: :group_users
  has_many :payments

  validates :name, presence: true

  def as_json(options={})
    methods = options[:user_id].present? ? [] : %i(active_users invited_users)

    super methods: methods
  end

  def active_users()
    users.where(group_users: {status: 'active'}).as_json(group_id: self.id)
  end

  def invited_users()
    users.where(group_users: {status: 'inviting'}).as_json(group_id: self.id)
  end
end
