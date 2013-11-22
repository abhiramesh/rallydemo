class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :eid
      t.integer :creator_id
      t.string :all_members_count
      t.string :attending_count
      t.string :declined_count
      t.text :name
      t.text :pic_big
      t.string :start_time
      t.string :unsure_count
      t.text :location
      t.text :description
      t.string :source

      t.timestamps
    end
  end
end
