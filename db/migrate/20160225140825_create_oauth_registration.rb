class CreateOauthRegistration < ActiveRecord::Migration
  def change
    create_table :oauth_registrations do |t|
      t.references :user,           index: true, null: false
      t.references :oauth,          null: false
      t.string     :third_party_id, null: false
      t.date       :deleted_at

      t.timestamps
    end
  end
end
