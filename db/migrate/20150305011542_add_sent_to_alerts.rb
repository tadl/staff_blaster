class AddSentToAlerts < ActiveRecord::Migration
	def self.up
    	add_column :alerts, :sent, :boolean
  	end
  	def self.down
    	remove_column :alerts, :sent
  	end
end
