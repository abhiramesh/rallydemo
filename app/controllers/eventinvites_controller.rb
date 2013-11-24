class EventinvitesController < ApplicationController

	before_filter :authenticate_user!

	require 'mechanize'

	def index
		if params[:waiting]
			@job_id = params[:waiting]
		end
		@eventinvites = current_user.eventinvites
	end

	def get_event_coordinates
		@eventinvites = current_user.eventinvites
		@events_array = []

		@eventinvites.each do |invite|
			hash = Hash.new
			if invite.event.location
				event_location = invite.event.location
			else
				event_location = ""
			end
			a = Mechanize.new
			response = a.get("http://maps.googleapis.com/maps/api/geocode/json?address=" + event_location + "&sensor=false")
			if JSON.parse(response.content) && JSON.parse(response.content)["results"] && JSON.parse(response.content)["results"][0] && JSON.parse(response.content)["results"][0]["geometry"] && JSON.parse(response.content)["results"][0]["geometry"]["bounds"] && JSON.parse(response.content)["results"][0]["geometry"]["bounds"]["northeast"]
				lat = JSON.parse(response.content)["results"][0]["geometry"]["bounds"]["northeast"]["lat"]
				lng = JSON.parse(response.content)["results"][0]["geometry"]["bounds"]["northeast"]["lng"]
				hash.merge!("lat" => lat.to_s)
				hash.merge!("lng" => lng.to_s)
			end
			hash.merge!("name" => invite.event.name)
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

