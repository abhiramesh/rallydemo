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
			job = Delayed::Job.find(params["job_id"].to_i)
			if job
				render json: { message: "no" }
			else
				render json: { message: "ready" }
			end
		else
			render json: { message: "error" }
		end
	end


end

