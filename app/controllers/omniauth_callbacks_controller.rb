class OmniauthCallbacksController < Devise::OmniauthCallbacksController

	def facebook
		omniauth = request.env["omniauth.auth"]
		omniauth['extra']['raw_info']['email'] ? email =  omniauth['extra']['raw_info']['email'] : email = ''
		omniauth['extra']['raw_info']['name'] ? name =  omniauth['extra']['raw_info']['name'] : name = ''
		omniauth['extra']['raw_info']['id'] ?  uid =  omniauth['extra']['raw_info']['id'] : uid = ''
		omniauth['provider'] ? provider =  omniauth['provider'] : provider = ''
		omniauth['credentials']['token'] ? oauth_token =  omniauth['credentials']['token'] : oauth_token = ''
		omniauth['credentials']['expires_at'] ? oauth_expires_at = omniauth['credentials']['expires_at'] : oauth_expires_at = ''
		
		user = User.where(email: email).first
		if user
			sign_in_and_redirect user
		else
			new_user = User.create(email: email, name: name, password: Devise.friendly_token, provider: provider, oauth_token: oauth_token, oauth_expires_at: oauth_expires_at, uid: uid)
			graph = new_user.facebook
			if new_user.save
			    if graph
			      g = graph.fql_query("SELECT url FROM square_profile_pic WHERE id = me() AND size=200")
			      g = JSON.parse(g.to_json)
			      image = g[0]["url"]
			      new_user.profile_image = image
			      new_user.save!
			    end
			    job = new_user.delay.get_user_info
			    sign_in new_user
			    redirect_to eventinvites_path(:waiting => job.id)
			else
				redirect_to root_path
			end
		end
	end

end
