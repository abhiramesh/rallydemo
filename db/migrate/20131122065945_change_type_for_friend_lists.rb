class ChangeTypeForFriendLists < ActiveRecord::Migration
  def up
  	rename_column :friendlists, :type, :ftype
  end

  def down
  end
end
