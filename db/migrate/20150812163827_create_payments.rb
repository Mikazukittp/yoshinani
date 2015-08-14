class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :amount
      t.string :event
      t.string :description
      t.date :date
      t.references :paid_user, references: :users, index: true

      t.timestamps
    end
  end
end
