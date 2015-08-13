class AddColumnToPayment < ActiveRecord::Migration
  def change
    add_reference :payments, :group, index: true
  end
end
