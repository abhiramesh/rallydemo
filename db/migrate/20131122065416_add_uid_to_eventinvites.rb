class AddUidToEventinvites < ActiveRecord::Migration
  def change
    add_column :eventinvites, :uid, :string
  end
end
