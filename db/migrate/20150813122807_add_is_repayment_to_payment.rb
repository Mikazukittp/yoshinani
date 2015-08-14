class AddIsRepaymentToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :is_repayment, :boolean, default: false
  end
end
