class GroupMemberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present?
      return if GroupUser.exists?(user_id: value, group_id: record.group_id)

      record.errors.add attribute, '指定されたgroupに所属されておりません'
    end
  end
end
