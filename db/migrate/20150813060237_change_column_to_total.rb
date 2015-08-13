class ChangeColumnToTotal < ActiveRecord::Migration
  def up
    change_column :totals, :to_pay, :decimal, :precision => 11, :scale => 2
    change_column :totals, :paid, :decimal, :precision => 11, :scale => 2
  end

  def down
    change_column :totals, :to_pay, :integer
    change_column :totals, :paid, :integer
  end
end
