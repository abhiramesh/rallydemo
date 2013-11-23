class EventinvitesController < ApplicationController

	before_filter :authenticate_user!

	def index
		if params[:waiting]
			@job_id = params[:waiting]
		end
		@eventinvites = current_user.eventinvites
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


end

