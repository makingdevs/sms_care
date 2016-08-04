require 'singleton'
require 'date'
require './models/scheduled_message'

class ScheduleMessagesManager
  include Singleton

  def initialize
  end

  def retrieve_scheduled_messages(secret)
    scheduled_messages = ScheduledMessage.order(id: :desc).all
    p scheduled_messages
    messages = scheduled_messages.map do |m|
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

  def confirm_scheduled_messages
  end

  def create_message(params)
    ScheduledMessage.new(
      "body" => params["body"],
      "phone_number" => params["phone_number"],
      "scheduled_date" => Date.parse(params["scheduled_date_submit"]),
      "status" => "pending",
      "uuid" => SecureRandom.uuid
    )
  end
end