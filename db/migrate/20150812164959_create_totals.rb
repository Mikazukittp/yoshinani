class CreateTotals < ActiveRecord::Migration
  def change
    create_table :totals do |t|
      t.integer :paid
      t.integer :to_pay
      t.references :group, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
