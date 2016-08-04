require 'singleton'
require './models/scheduled_message'

class ScheduleMessagesManager
  include Singleton

  def initialize
  end

  def retrieve_scheduled_messages
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
