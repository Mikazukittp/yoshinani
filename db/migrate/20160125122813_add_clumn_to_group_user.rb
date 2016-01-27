class AddClumnToGroupUser < ActiveRecord::Migration
  def change
    add_column :group_users, :role, :string, null: false, default: 'member'
    add_column :group_users, :status, :string, null: false, default: 'inviting'
  end
end
