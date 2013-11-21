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
			User.create(email: email, name: name, password: Devise.friendly_token, provider: provider, oauth_token: oauth_token, oauth_expires_at: oauth_expires_at, uid: uid)
			redirect_to root_path
		end
	end

end
