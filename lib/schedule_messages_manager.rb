require 'singleton'
require 'date'
require './models/scheduled_message'

class ScheduleMessagesManager
  include Singleton

  def initialize
  end

  def retrieve_scheduled_messages(secret)
    # TODO: Validate the secret
    scheduled_messages = ScheduledMessage.where(
      scheduled_date: (Time.now.midnight - 1.day)..Time.now.midnight,
      status: "pending")
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
    scheduled_messages = ScheduledMessage.where(
      scheduled_date: (Time.now.midnight - 1.day)..Time.now.midnight,
      status: "pending")
    scheduled_messages.each do |m|
      m.status = "queued"
    end
    ScheduledMessage.transaction do
      scheduled_messages.each(&:save!)
    end
    scheduled_messages
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
