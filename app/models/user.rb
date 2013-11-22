class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :provider, :oauth_token, :oauth_expires_at, :uid, :profile_image
  
  has_many :friends, dependent: :destroy

  has_many :eventinvites, dependent: :destroy
  has_many :events, through: :eventinvites
  has_many :friendlists

  def facebook
    @facebook ||= Koala::Facebook::API.new(self.oauth_token)
  end

  def get_user_info
  	if self.facebook
		g = self.facebook.fql_multiquery({ "friends" => "SELECT uid2 FROM friend WHERE uid1=me()", "fullfriends" => "SELECT name,uid,pic_square FROM user WHERE uid IN (SELECT uid2 FROM #friends)", "myevents" => "SELECT eid, uid, rsvp_status FROM event_member WHERE uid = me()", "myeventdetails" => "SELECT eid, all_members_count, attending_count, declined_count, name, pic_big, start_time, unsure_count, location, description FROM event WHERE eid IN (SELECT eid FROM #myevents)", "friendlists" => "SELECT count, flid, name, type FROM friendlist WHERE owner = me()", "friendlistmembers" => "SELECT uid, flid FROM friendlist_member WHERE flid IN (SELECT flid FROM #friendlists)" })
  		if g
  			my_array = JSON.parse(g.to_json)
	    	friends_hash = my_array["fullfriends"]
	    	events_hash = my_array["myevents"]
	    	eventdetails_hash = my_array["myeventdetails"]
	    	if events_hash && eventdetails_hash
	    		events_hash.each do |f|
	    			eventdetails_hash.select {|e| e["eid"] == f["eid"]}.first.merge!("rsvp_status" => f["rsvp_status"])
	    		end
	    	end
	    	friendlists_hash = my_array["friendlists"]
	    	friendlistmembers_hash = my_array["friendlistmembers"]

	    	if friends_hash
		    	inserts = []
			    friends_hash.map { |d| inserts.push "(#{ActiveRecord::Base.sanitize(self.id)}, #{ActiveRecord::Base.sanitize(d["name"])}, #{ActiveRecord::Base.sanitize(d["uid"])}, #{ActiveRecord::Base.sanitize(d["pic_square"])}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))})" }
			    begin
			    Friend.connection.execute "INSERT INTO friends (user_id, name, uid, pic_square, created_at, updated_at) values #{inserts.join(", ")}"
				rescue
				end
			end

			if eventdetails_hash
			    inserts = []
			    eventdetails_hash.map { |d| inserts.push "(#{ActiveRecord::Base.sanitize(d["eid"])}, #{ActiveRecord::Base.sanitize(d["all_members_count"])}, #{ActiveRecord::Base.sanitize(d["attending_count"])}, #{ActiveRecord::Base.sanitize(d["declined_count"])}, #{ActiveRecord::Base.sanitize(d["name"])}, #{ActiveRecord::Base.sanitize(d["pic_big"])}, #{ActiveRecord::Base.sanitize(d["start_time"])}, #{ActiveRecord::Base.sanitize(d["unsure_count"])}, #{ActiveRecord::Base.sanitize(d["location"])}, #{ActiveRecord::Base.sanitize(d["description"])}, #{ActiveRecord::Base.sanitize("facebook")}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))})" }
			    begin
			    Event.connection.execute "INSERT INTO events (eid, all_members_count, attending_count, declined_count, name, pic_big, start_time, unsure_count, location, description, source, created_at, updated_at) values #{inserts.join(", ")}"
				rescue
				end
				inserts = []
				events_hash.map { |d| inserts.push "(#{ActiveRecord::Base.sanitize(self.id)}, #{ActiveRecord::Base.sanitize(d["eid"])}, #{ActiveRecord::Base.sanitize(d["uid"])}, #{ActiveRecord::Base.sanitize(d["rsvp_status"])}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))})" }
			    begin
			    Eventinvite.connection.execute "INSERT INTO eventinvites (user_id, eid, uid, rsvp_status, created_at, updated_at) values #{inserts.join(", ")}"
				rescue
				end
				self.eventinvites.each do |i|
					if i.event_id == nil
						i.event_id = Event.where(eid: i.eid).first.id
						i.save!
					end
				end
			end

			if friendlists_hash
				inserts = []
			    friendlists_hash.map { |d| inserts.push "(#{ActiveRecord::Base.sanitize(self.id)}, #{ActiveRecord::Base.sanitize(d["count"])}, #{ActiveRecord::Base.sanitize(d["flid"])}, #{ActiveRecord::Base.sanitize(d["name"])}, #{ActiveRecord::Base.sanitize(d["type"])}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))})" }
			    begin
			    Friendlist.connection.execute "INSERT INTO friendlists (user_id, count, flid, name, ftype, created_at, updated_at) values #{inserts.join(", ")}"
			    rescue
			    end
			    inserts = []
			    friendlistmembers_hash.map { |d| inserts.push "(#{ActiveRecord::Base.sanitize(d["uid"])}, #{ActiveRecord::Base.sanitize(d["flid"])}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))})" }
			    begin
			    Friendlistmember.connection.execute "INSERT INTO friendlistmembers (uid, flid, created_at, updated_at) values #{inserts.join(", ")}"
			    rescue
			    end
			    self.friendlists.each do |list|
			    	if Friendlistmember.where(flid: list.flid, friendlist_id: nil)
			    		Friendlistmember.where(flid: list.flid, friendlist_id: nil).each do |i|
					    	if i
					    		i.friendlist_id = list.id
					    		i.save!
					    	end
					    end
				    end
			    end
			end
		end
		self.delay.get_friend_info
  	end
  end

  def get_friend_info
  	if self.facebook
	  	f = self.facebook.batch do |b|
	      (0..9).each do |var|
	        var=var*400
	        b.fql_multiquery({ "friends" => "SELECT uid2 FROM friend WHERE uid1=me() LIMIT 400 OFFSET #{var}", "myfriendsevents" => "SELECT eid, uid, rsvp_status FROM event_member WHERE uid IN (SELECT uid2 FROM #friends) LIMIT 10", "myfriendseventdetails" => "SELECT eid,all_members_count, attending_count, declined_count, name, pic_big, start_time, unsure_count, location, description FROM event WHERE eid IN (SELECT eid FROM #myfriendsevents)"})
	      end
	    end
	    if f
	    	f.each do |h|
	    		if h
	    			friend_array = JSON.parse(h.to_json)
	    			if friend_array
	    				events_hash = friend_array[1]["fql_result_set"]
	    				eventdetails_hash = friend_array[2]["fql_result_set"]
				    	if events_hash && eventdetails_hash
				    		events_hash.each do |f|
				    			eventdetails_hash.select {|e| e["eid"] == f["eid"]}.first.merge!("rsvp_status" => f["rsvp_status"])
				    		end
				    		inserts = []
		    				eventdetails_hash.map { |d| inserts.push "(#{ActiveRecord::Base.sanitize(d["eid"].to_s)}, #{ActiveRecord::Base.sanitize(d["all_members_count"].to_s)}, #{ActiveRecord::Base.sanitize(d["attending_count"].to_s)}, #{ActiveRecord::Base.sanitize(d["declined_count"].to_s)}, #{ActiveRecord::Base.sanitize(d["name"])}, #{ActiveRecord::Base.sanitize(d["pic_big"])}, #{ActiveRecord::Base.sanitize(d["start_time"].to_s)}, #{ActiveRecord::Base.sanitize(d["unsure_count"].to_s)}, #{ActiveRecord::Base.sanitize(d["location"].to_s)}, #{ActiveRecord::Base.sanitize(d["description"].to_s)}, #{ActiveRecord::Base.sanitize("facebook")}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))})" }
				    		begin
				    		Event.connection.execute "INSERT INTO events (eid, all_members_count, attending_count, declined_count, name, pic_big, start_time, unsure_count, location, description, source, created_at, updated_at) values #{inserts.join(", ")}"
				    		rescue
				    		end
				    		inserts = []
							events_hash.map { |d| inserts.push "(#{ActiveRecord::Base.sanitize(d["eid"].to_s)}, #{ActiveRecord::Base.sanitize(d["uid"].to_s)}, #{ActiveRecord::Base.sanitize(d["rsvp_status"].to_s)}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))}, #{ActiveRecord::Base.sanitize(Time.now.utc.to_s(:db))})" }
						    begin
						    Eventinvite.connection.execute "INSERT INTO eventinvites (eid, uid, rsvp_status, created_at, updated_at) values #{inserts.join(", ")}"
						    rescue
						    end
						    self.friends.each do |f|
						    	if Eventinvite.where(uid: f.uid, friend_id: nil)
						    		Eventinvite.where(uid: f.uid, friend_id: nil).each do |i|
						    			i.friend_id = f.id
						    			i.save!
						    		end
						    	end
						    end
				    	end
	    			end
	    		end
	    	end
	    end
	end
  end


end
