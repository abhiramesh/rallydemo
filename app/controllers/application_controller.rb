class ApplicationController < ActionController::Base
  protect_from_forgery


  def after_sign_in_path_for(resource)
  	eventinvites_path
  end

  def after_sign_out_path_for(resource)
  	root_path
  end

  private

  def authenticate_user_from_token!
  	user_token = params["user_token"].presence
  	user = user_token && User.find_by_authentication_token(user_token)
  	if user
  		sign_in user
  	else
  		render json: "Invalid Login Information"
  	end
  end


end
