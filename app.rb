require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/activerecord'
require './config/environments' #database configuration
require './models/message'
require './lib/auto_response'
require 'json'

# Home page
get '/' do
  p params
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

get '/messages' do
  @messages = Message.order(id: :desc).all # Get all the messages
  erb :index # Showing the index.erb
end

get '/scheduled_message/new' do
  erb :scheduled_message # Showing the index.erb
end

post '/scheduled_message/save' do
  p params
  redirect to('/scheduled_message/new')
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

