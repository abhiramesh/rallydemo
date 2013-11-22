class Event < ActiveRecord::Base
  attr_accessible :all_members_count, :attending_count, :creator_id, :declined_count, :description, :eid, :location, :name, :pic_big, :source, :start_time, :unsure_count

  has_many :eventinvites
  has_many :users, through: :eventinvites
end
