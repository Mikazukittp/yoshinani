class CreateNortificationTokens < ActiveRecord::Migration
  def change
    create_table :nortification_tokens do |t|
      t.text :device_token
      t.string :device_type
      t.references :user, index: true
      t.timestamps
    end
  end
end
