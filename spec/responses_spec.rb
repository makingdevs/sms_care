require './lib/auto_response'

# The test for verify if the searching of messsages is right
RSpec.describe AutoResponse do
  [
    ["some 111 some","Thank you for contacting SMS Care. Our team will contact you soon for a free care referral."],
    #["some some","Please write us and include some code: 111 for contact, 222 for meet you better, 333 for mor info"],
    ["another response with 222","Thank you for contacting SMS Care. What is the name and age of your child? end with 221 code"]
  ].each do | sms, response |
    it "SMS is #{sms} and response is #{response}" do
      current_response = AutoResponse.instance.respond_to(sms)
      expect(current_response).to eq(response)
    end
  end
end

