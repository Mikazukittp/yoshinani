class CreateNotificationTokens < ActiveRecord::Migration
  def change
    create_table :notification_tokens do |t|
      t.text :device_token, unique: true
      t.string :device_type
      t.references :user, index: true
      t.timestamps
    end
  end
end
