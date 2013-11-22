class Friendlistmember < ActiveRecord::Base
  attr_accessible :flid, :friendlist_id, :uid

  belongs_to :friendlist
end
