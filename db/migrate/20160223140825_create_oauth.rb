class CreateOauth < ActiveRecord::Migration
  def change
    create_table :oauths do |t|
      t.references :user, index: true, null: false
      t.string :name, null: false
      t.string :auth_id, null: false
      t.date :deleted_at

      t.timestamps
    end
  end
end
