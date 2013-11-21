class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :provider, :oauth_token, :oauth_expires_at, :uid
  
  def facebook
    @facebook ||= Koala::Facebook::API.new(self.oauth_token)
  end

  def get_user_info
	g = self.facebook.fql_multiquery({ "friends" => "SELECT uid2 FROM friend WHERE uid1=me()", "friendnames" => "SELECT name,uid FROM user WHERE uid IN (SELECT uid2 FROM #friends)", "friendimages" => "SELECT id,url FROM square_profile_pic WHERE id in (SELECT uid2 FROM #friends) AND size=150", "myevents" => "SELECT eid, uid, rsvp_status FROM event_member WHERE uid = me()", "myeventdetails" => "SELECT all_members_count, attending_count, declined_count, name, pic_big, start_time, unsure_count, location, description FROM event WHERE eid IN (SELECT eid FROM #myevents)", "friendlists" => "SELECT count, flid, name, type FROM friendlist WHERE owner = me()", "friendlistmembers" => "SELECT uid, flid FROM friendlist_member WHERE flid IN (SELECT flid FROM #friendlists)" })
  end

  def get_friend_info
  	f = self.facebook.batch do |b|
      (0..49).each do |var|
        var=var*100
        b.fql_multiquery({ "friends" => "SELECT uid2 FROM friend WHERE uid1=me() LIMIT 100 OFFSET #{var}", "myfriendsevents" => "SELECT eid, uid, rsvp_status FROM event_member WHERE uid IN (SELECT uid2 FROM #friends)", "myfriendseventdetails" => "SELECT all_members_count, attending_count, declined_count, name, pic_big, start_time, unsure_count, location, description FROM event WHERE eid IN (SELECT eid FROM #myfriendevents)"})
      end
    end
  end


end
