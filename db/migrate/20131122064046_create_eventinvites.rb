class CreateEventinvites < ActiveRecord::Migration
  def change
    create_table :eventinvites do |t|
      t.integer :user_id
      t.string :eid
      t.string :rsvp_status
      t.integer :event_id

      t.timestamps
    end
    add_index :eventinvites, :user_id
    add_index :eventinvites, :event_id
  end
end
