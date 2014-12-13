require 'open-uri'
require 'securerandom'

Envyable.load('./config/env.yml', settings.env.to_s)
echoprint = EchoPrint.new(ENV['ECHONEST_API_KEY'])

post '/voice' do
  uuid = SecureRandom.uuid
  number = params['From']
  content_type 'text/xml'
  response = Twilio::TwiML::Response.new do |r|
    r.Record(
      :action => "/recording/#{uuid}",
      :maxLength => 30,
      :playBeep => false
    )
  end
  response.to_xml
end

post '/recording/:id' do
  mp3_url = "#{params["RecordingUrl"]}.mp3"
  uri = URI(mp3_url)

  Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Get.new uri

    http.request request do |response|
      FileUtils.mkdir_p './tmp'
      File.open "./tmp/#{params[:id]}.mp3", 'w' do |io|
        response.read_body do |chunk|
          io.write chunk
        end
      end
    end
  end

  echoprint.identify("./tmp/#{params[:id]}.mp3")
end


