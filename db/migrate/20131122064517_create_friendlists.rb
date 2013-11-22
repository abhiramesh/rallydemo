class CreateFriendlists < ActiveRecord::Migration
  def change
    create_table :friendlists do |t|
      t.integer :user_id
      t.string :count
      t.string :flid
      t.string :name
      t.string :type

      t.timestamps
    end
    add_index :friendlists, :user_id
  end
end
