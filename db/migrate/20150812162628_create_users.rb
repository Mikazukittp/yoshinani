class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :account
      t.string :username
      t.string :email
      t.string :password
      t.string :token
      t.integer :role

      t.timestamps
    end
  end
end
