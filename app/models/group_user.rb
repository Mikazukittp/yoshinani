class GroupUser < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  validates :group_id, presence: true
  validates :user_id, presence: true
  validate :composite_primary_key
  # シンプルに下記のvalidatesでもできるが、errorsのメッセージをstatusで出し分けられない
  # validates :group_id,
  #   uniqueness: {
  #     message: "このユーザはすでにグループに招待済みです.",
  #     scope: [:user_id]
  #   }

  def composite_primary_key
    relation = GroupUser.where(group_id: group.id, user_id: user.id)
    if relation.present?
      status = relation.first.status == :active ? "メンバー" : "招待中"
      errors[:base] << "このユーザはすでに" + status + "です"
    end
  end

end
