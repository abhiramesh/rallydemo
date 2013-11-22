class ApplicationController < ActionController::Base
  protect_from_forgery

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
