class AddIconImgToUser < ActiveRecord::Migration
  def change
    add_column :users, :icon_img, :text
  end
end
