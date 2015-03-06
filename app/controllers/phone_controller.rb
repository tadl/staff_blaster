require 'twilio-ruby'
class PhoneController < ApplicationController
	include Webhookable
	after_filter :set_header		
  skip_before_filter  :verify_authenticity_token

  def number_to_location(location_code)
    location_code = location_code.to_s
    if location_code == '1'
      location ='All district locations'
    elsif location_code == '2'
      location = 'Woodmere'
    elsif location_code == '3'
      location = 'Kingsley'
    elsif location_code == '4'
      location = 'East Bay'
    end
    puts location
    return location
  end

  def location_to_number(location_name)
    if location_name == 'All district locations'
      location = '1'
    elsif location_name == 'Woodmere'
      location = '2'
    elsif location_name == 'Kingsley'
      location = '3'
    elsif location_name == 'East Bay'
      location = '4'
    end
    return location
  end

  def receive
    active_alerts = Alert.where(active: true)
    alert_count = active_alerts.count.to_i
    if alert_count > 0
      alerts = "Active alerts. Stay on the line for details"
      next_action = 'verify_admin?alerts=active'
    else
      alerts = "There no emergencies or delays to report"
      next_action = 'verify_admin'
    end
  	response = Twilio::TwiML::Response.new do |r|
    	r.Say alerts
      if alert_count > 0
        active_alerts.each do |a|
          location_name = number_to_location(a.location)
          r.Say 'This alert is for ' + location_name
          r.Play a.url
        end
        r.Say "No further alerts"
      end
    	r.Gather :numDigits => '6', :action => next_action, :method => 'get' do |g|
    	  g.Say 'Authorized users may enter their PIN at anytime'
    	end
  	end
  	render_twiml response
  end

  def verify_admin
  	# Enventually Create Array of PINs tied to admin user
  	if params['alerts'] == 'active'
      next_action = 'prompt_clear_alerts'    
    else
      next_action = 'select_location'
    end
    if params['Digits'] != '123456'
  		response = Twilio::TwiML::Response.new do |r|
    		r.Say 'Invalid PIN'
    		r.Redirect('receive')
    	end	
    else
      response = Twilio::TwiML::Response.new do |r|
        r.Redirect(next_action)
      end
  	end
  	render_twiml response
  end
  
  def prompt_clear_alerts 
    active_alerts = Alert.where(active: true)
    alerted_locations = Array.new
    active_alerts.each do |a|
      alert = Hash.new
      puts a.location.to_s
      alert['location_code'] = a.location
      alert['location_name'] = number_to_location(alert['location_code'])
      alerted_locations.push(alert)
    end
    alerted_locations.uniq!
    response = Twilio::TwiML::Response.new do |r|
      r.Say "Active alerts"
      r.Gather :numDigits => '1', :action => 'clear_alerts', :method => 'get' do |g|
        alerted_locations.each do |a|
          g.Say 'To clear active alerts at ' + a['location_name'] + ' press ' + a['location_code'].to_s
        end
          g.Say 'To record a new alert press any other key'
      end
    end
    render_twiml response
  end

  def clear_alerts
    if !['1','2','3','4'].include? params['Digits']
      response = Twilio::TwiML::Response.new do |r|
        r.Redirect('select_location')
      end  
    else
      location_code = params['Digits']
      location_name = number_to_location(location_code)
      alerts_to_clear = Alert.where(active: true, location: location_code)
      alerts_to_clear.each do |a|
        a.destroy 
      end
      active_alerts = Alert.where(active: true)
      alert_count = active_alerts.count.to_i
      if alert_count > 0
        next_action = 'prompt_clear_alerts'
      else
        next_action = 'select_location'
      end
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'The alert for ' + location_name + ' has been cleared'
        r.Redirect(next_action)
      end  
    end
    render_twiml response
  end

  def select_location
    response = Twilio::TwiML::Response.new do |r|
      r.Gather :numDigits => '1', :action => 'record_message', :method => 'get' do |g|
        g.Say 'Press 1 to record a message for the entire district. Press 2 for Woodmere. Press 3 for Kingsley. Press 4 for East Bay'
      end
    end
    render_twiml response
  end

  def record_message
    if !['1','2','3','4'].include? params['Digits'] 
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Invalid option'
        r.Redirect('select_location')
      end 
    else
      location = number_to_location(params['Digits'])
      next_action = 'review_call?location=' + params['Digits'] 
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Recording message for ' + location
        r.Say 'At the tone please record a message. Hit any key when finished'
        r.Record :maxLength => '180', :action => next_action, :method => 'get'
      end
    end
    render_twiml response 
  end

  def review_call
    location = number_to_location(params['location'])
    next_action = 'send_message?location=' + params['location'] + '&url=' + params['RecordingUrl']
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Playing back your message for ' + location
      r.Play params['RecordingUrl']
      r.Gather :numDigits => '1', :action => next_action, :method => 'get' do |g|
        r.Say 'Press 1 to confirm and send messsage to ' + location + ' or press any other key to record a new message'
      end
    end
    render_twiml response 
  end

  def send_message
    if params['Digits'] != '1'
      puts 
      back_action = 'record_message?Digits=' + params['location']  
      response = Twilio::TwiML::Response.new do |r|
        r.Redirect(back_action)
      end 
    else
      location = number_to_location(params['location'])
      puts params[:url].to_s
      response = Twilio::TwiML::Response.new do |r|
        r.Say 'Your message will be sent to all staff at ' + location + ' within the next five minutes'
        r.Say 'Have a good day, be safe and may the force be with you'
        r.Say 'Goodbye'
      end
      new_alert = Alert.new
      new_alert.url = params['url']
      new_alert.location = params['location']
      new_alert.active = true
      new_alert.sent = false
      new_alert.save
    end
    render_twiml response 
  end
end
