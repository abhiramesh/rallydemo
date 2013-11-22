class CreateFriendlistmembers < ActiveRecord::Migration
  def change
    create_table :friendlistmembers do |t|
      t.integer :friendlist_id
      t.string :uid
      t.string :flid

      t.timestamps
    end
    add_index :friendlistmembers, :friendlist_id
  end
end
