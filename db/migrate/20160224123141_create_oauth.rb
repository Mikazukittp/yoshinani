class CreateOauth < ActiveRecord::Migration
  def change
    create_table :oauths do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
