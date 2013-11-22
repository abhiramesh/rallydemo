class Eventinvite < ActiveRecord::Base
  attr_accessible :eid, :event_id, :rsvp_status, :user_id, :uid, :friend_id

  belongs_to :user
  belongs_to :event

  belongs_to :friend
end
