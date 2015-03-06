class Person < ActiveRecord::Base
	validates_uniqueness_of :email, :message => "User with email already in DB"
	validates_uniqueness_of :gapp_id, :message => "User with google apps id in DB"
end
