require 'open-uri'
require './lib/echoprint'

Envyable.load('./config/env.yml', settings.env.to_s)
echoprint = EchoPrint.new(ENV['ECHONEST_API_KEY'])

Twilio.configure do |config|
  config.account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.auth_token  = ENV['TWILIO_AUTH_TOKEN']
end

post '/voice' do
  content_type 'text/xml'
  response = Twilio::TwiML::Response.new do |r|
    r.Record(
      :action => "/recording",
      :maxLength => 30,
      :playBeep => false
    )
  end
  response.to_xml
end

post '/recording' do
  number = params["From"]
  id = params["RecordingSid"]
  mp3_url = "#{params["RecordingUrl"]}.mp3"
  file_path = "./tmp/#{id}.mp3"

  # client = Twilio::REST::Client.new
  # client.messages.create(
  #   :to   => number,
  #   :from => '+442033898457',
  #   :body => 'Thanks for the call, we will have your song shortly.'
  # )

  uri = URI(mp3_url)

  Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Get.new uri

    http.request request do |response|
      FileUtils.mkdir_p './tmp'
      File.open file_path, 'w' do |io|
        response.read_body do |chunk|
          io.write chunk
        end
      end
    end
  end

  puts echoprint.identify(file_path).inspect
end


