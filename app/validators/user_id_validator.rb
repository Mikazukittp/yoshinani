class UserIdValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present?
      User.find(value).present?
    end
  end
end
