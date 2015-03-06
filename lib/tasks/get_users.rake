desc "Get List of All Users"
task :get_users => :environment do
	require 'google/api_client'
	require 'google/api_client/client_secrets'
	require 'google/api_client/auth/installed_app'

  	def create_directory_client()
  	  key_secret = 'notasecret'
  	  service_account_email = ENV['service_account_email']
  	  keypath = Rails.root.join('config', ENV['service_account_key_name']).to_s
  	  client = Google::APIClient.new(
  	    :application_name => 'tadl_gcal',
  	    :application_version => '1.0.0'
  	  )
  	  permissions = ['https://www.googleapis.com/auth/admin.directory.user.readonly', 
  	    'https://www.googleapis.com/auth/admin.directory.group.readonly',
  	    'https://www.googleapis.com/auth/admin.directory.group.member.readonly'
  	  ]
  	  key = Google::APIClient::KeyUtils.load_from_pkcs12(keypath, key_secret)
  	  asserter = Google::APIClient::JWTAsserter.new(service_account_email, permissions, key)
  	  client.authorization = asserter.authorize(ENV['admin_email'])
  	  return client
  	end


  	client = create_directory_client()
	directory_api = client.discovered_api('admin', 'directory_v1')
	user_api_request = client.execute({
  	api_method: directory_api.users.list,
  	parameters: {
    	domain: 'tadl.org',
    	maxResults: 500
  	}
	})
	users = []
	user_api_request.data.users.each do |u|
		if !u['includeInGlobalAddressList'] == false && u['suspended'] == false
			user = Hash.new
			user['name'] = u['name']['fullName']
			user['first_name'] = u['name']['givenName'].downcase
			user['last_name'] = u['name']['familyName'].downcase
			user['email'] = u['primaryEmail']
			puts user['name']
			users = users.push(user)
		end	
	end

	users.each do |u|
		staff_member = Person.new
		staff_member.full_name = u['name']
		staff_member.first_name = u['first_name']
		staff_member.last_name = u['last_name']
		staff_member.email = u['email']
		staff_member.gapp_id = u['id']
		staff_member.save 
	end

end