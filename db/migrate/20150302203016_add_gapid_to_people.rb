class AddGapidToPeople < ActiveRecord::Migration
  def change
  	 def self.up
    	add_column :people, :gapp_id, :string, :unique => true
  	end
  	def self.down
    	remove_column :people, :gapp_id
  	end
  end
end
