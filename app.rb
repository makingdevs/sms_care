require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/activerecord'
require './config/environments' #database configuration
require './models/message'
require './models/scheduled_message'
require './lib/auto_response'
require 'json'
require 'date'

get '/' do
  respond_message(params["secret"]).to_json
end

post '/' do # receiving messages from SMSsync
  message = Message.new(params) # Creating an object
  content_type :json # Preparing the response
  if message.save
    success_response(message).to_json # Send a success message
  else
    error_response(message).to_json # Senad an error message
  end
end

# Message page
get '/messages' do
  @messages = Message.order(id: :desc).all # Get all the messages
  erb :index # Showing the index.erb
end

get '/scheduled_message/new' do
  erb :scheduled_message # Showing the index.erb
end

post '/scheduled_message/save' do
  scheduled_message = prepare_scheduled_message(params)
  if scheduled_message.save
    redirect to('/scheduled_message/list')
  else
    redirect to('/scheduled_message/new')
  end
end

get '/scheduled_message/list' do
  @scheduled_messages = ScheduledMessage.order(id: :desc).all
  erb :scheduled_message_list
end

private

def respond_message(secret)
  {
    "payload" =>
    {
      "secret" => "#{secret}",
      "task": "send",
     "messages": [
                 ]
    }
  }
end

def success_response(message)
  response = {
    "payload" =>
    {
      "success" => true,
      "error" => nil
    }
  }
  unless message.message.scan(/([M|m]ecate)/).empty? then
    response["payload"]["task"] = "send"
    response["payload"]["messages"] = [
      {
        "to": "#{message.from}",
       "message": AutoResponse.instance.respond_to(message.message),
       "uuid": "#{message.message_id}"
      }
    ]
  end

  response
end

def error_response(message)
  {
    "payload" =>
    {
      "success" => false,
      "error" => "Cannot save the message",
      "task": "send",
     "messages": [
                   {
                     "to": "#{message.from}",
                    "message": "Try  again",
                    "uuid": "#{message.message_id}"
                   }
                 ]
    }
  }
end

def prepare_scheduled_message(params)
  ScheduledMessage.new(
    "body" => params["body"],
    "phone_number" => params["phone_number"],
    "scheduled_date" => Date.parse(params["scheduled_date_submit"]),
    "status" => "pending"
  )
end
