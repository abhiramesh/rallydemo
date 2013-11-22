class Eventinvite < ActiveRecord::Base
  attr_accessible :eid, :event_id, :rsvp_status, :user_id, :uid

  belongs_to :user
  belongs_to :event
end
