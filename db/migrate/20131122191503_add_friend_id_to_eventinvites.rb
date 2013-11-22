class AddFriendIdToEventinvites < ActiveRecord::Migration
  def change
    add_column :eventinvites, :friend_id, :integer
  end
end
