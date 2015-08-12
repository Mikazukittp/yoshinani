class Payment < ActiveRecord::Base
  belongs_to :paid_user, :class_name => 'User'
end
