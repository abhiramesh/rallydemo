class Api::V1::UsersController < ApplicationController

	def login
		if params["oauth_token"]
			graph = Koala::Facebook::API.new(params["oauth_token"])
			if graph
				me = graph.get_object("me")
				user = User.find_by_email(me["email"])
				if user
					sign_in user
					user.oauth_token = params["oauth_token"]
					user.save
					render json: {auth_token: user.authentication_token, email: user.email, sign_in_count: user.sign_in_count.to_s, image: user.profile_image}
				else
					uid = me["id"]
					name = me["name"]
					email = me["email"]	
					provider = 'facebook'				
					g = graph.fql_query("SELECT url FROM square_profile_pic WHERE id = me() AND size=200")
			      	g = JSON.parse(g.to_json)
			      	image = g[0]["url"]
			      	new_user = User.create(email: email, name: name, password: Devise.friendly_token, provider: provider, oauth_token: params["oauth_token"], uid: uid, profile_image: image)
					if new_user.save
						sign_in_user
						render json: {auth_token: user.authentication_token, email: user.email, sign_in_count: user.sign_in_count.to_s, image: user.profile_image}
						new_user.delay.get_user_info
					else
						render :json => {:status => "Something went wrong!"}
					end
				end
			else
				render :json => {:status => "Something went wrong!"}
			end
		else
			render :json => {:status => "Need a proper Facebook login"}
		end
	end	

end