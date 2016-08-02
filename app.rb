require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/activerecord'
require './config/environments' #database configuration
require './models/message'
require './lib/auto_response'
require 'json'

# Home page
get '/' do
  @messages = Message.order(id: :desc).all # Get all the messages
  erb :index # Showing the index.erb
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

private
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

