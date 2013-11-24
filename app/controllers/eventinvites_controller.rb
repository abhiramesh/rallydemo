class EventinvitesController < ApplicationController

	before_filter :authenticate_user!

	def index
		if params[:waiting]
			@job_id = params[:waiting]
		end
		@eventinvites = current_user.eventinvites
	end

	def get_event_list
		@eventinvites = current_user.eventinvites
		
		# current_user.friends.find_each do |f|
		# 	myinvites = f.eventinvites
		# 	@eventinvites.concat(myinvites)
		# end
		@events_array = []

		@eventinvites.each do |invite|
			hash = Hash.new
			if invite.event.location
				event_location = invite.event.location
			else
				event_location = ""
			end
			hash.merge!("name" => invite.event.name)
			hash.merge!("location" => event_location)
			@events_array << hash
		end
		render json: @events_array
	end

	def check_get_user_info_job
		if params["job_id"]
			job = Delayed::Job.find_by_id(params["job_id"].to_i)
			if job
				render json: "no"
			else
				render json: "ready"
			end
		else
			render json: "error"
		end
	end

	def showmodal
		event_id = params["id"].to_i
		puts "NIGGER"
		respond_to do |format|
			format.js { format.js { render "modal", :locals => {:event_id => event_id} } }
		end
	end


end

