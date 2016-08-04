require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/activerecord'
require './config/environments' #database configuration
require './models/message'
require './models/scheduled_message'
require './lib/auto_response'
require 'json'
require 'date'
require 'securerandom'

get '/' do
  puts "****************GET / **************"
  respond = case params["task"]
            when "send"
              respond_message(params["secret"])
            when "result"
              @scheduled_messages = ScheduledMessage.order(id: :desc).all
              {"message_uuids" => (@scheduled_messages.map { |m| m.uuid }) }
            else
              "no task defined"
            end
  content_type :json
  p respond
  respond.to_json
end

post '/' do # receiving messages from SMSsync
  puts "****************POST / **************"
  p params
  content_type :json # Preparing the response
  respond = case params[:task]
            when "sent"
              @scheduled_messages = ScheduledMessage.order(id: :desc).all
              {"message_uuids" => (@scheduled_messages.map { |m| m.uuid }) }
            when "result"
              @scheduled_messages = ScheduledMessage.order(id: :desc).all
              {"message_uuids" => (@scheduled_messages.map { |m| m.uuid }) }
            else
              message = Message.new(params) # Creating an object
              if message.save
                success_response(message) # Send a success message
              else
                error_response(message) # Senad an error message
              end
            end
  p respond
  respond.to_json
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
  # TODO: Retrieve the scheduled messages
  @scheduled_messages = ScheduledMessage.order(id: :desc).all
  messages = @scheduled_messages.map do |m|
    {
      "to" => m.phone_number,
      "message" => m.body,
      "uuid" => m.uuid,
    }
  end
  {
    "payload" =>
    {
      "secret" => "#{secret}",
      "task": "send",
     "messages": messages
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
    "status" => "pending",
    "uuid" => SecureRandom.uuid
  )
end
