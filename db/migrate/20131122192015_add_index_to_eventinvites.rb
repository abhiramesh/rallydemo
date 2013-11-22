class AddIndexToEventinvites < ActiveRecord::Migration
  def change
  	add_index :eventinvites, :friend_id
  end
end
