require 'singleton'
require 'open-uri'

class AutoResponse
  include Singleton

  def initialize
    url = "http://sms-care.makingdevs.com.s3.amazonaws.com/messages.txt" # The URL with the code messages
    message_text = open(url) { |io| io.read } # Reading the text file
    @responses = {} # The store of the messages
    message_text.split("\n").each do |line| # Iterating every line
      split_message = line.split('|') # Splitting for parsing
      @responses[split_message[0]] = split_message[1] # Store the message in the HashDict
    end
  end

  # The method to read the message and find the response
  def respond_to(message)
    code = message.scan(/\d{3}/).first # Searching the message in the SMS
    message = @responses.find { |k,v| k == code } # Finding the message
    if message # There's a message in our base of codes?
      message[1] # Return the message
    else
      """How can you help?  Funding: reply 111 [your msg] Viral: reply 222 [your msg] Community: reply 333 [your msg] Recommend Bar in MxCity: reply 444 [your msg]""" # Put a default message
    end
  end

end
