class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.references :payment, index: true
      t.references :group, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
