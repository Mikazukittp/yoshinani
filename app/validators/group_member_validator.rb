class GroupMemberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present?
      GroupUser.where(user_id: value, group_id: record.group_id).size.nonzero?
    end
  end
end
