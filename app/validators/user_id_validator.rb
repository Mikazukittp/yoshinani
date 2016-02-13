class UserIdValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present?
      return if User.exists?(id: value)

      record.errors.add attribute, '指定されたuserは存在しません'
    end
  end
end
