class AddResetPasswordTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :reset_password_token, :text
    add_column :users, :reset_password_at, :timestamp
  end
end
