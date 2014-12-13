require 'open-uri'

post '/voice' do
  content_type 'text/xml'
  '
  <Response>
    <Record action="/recording" maxLength="30" playBeep="false" />
  </Response>
  '
end

post '/recording' do
  mp3_url = "#{params["RecordingUrl"]}.mp3"
  uri = URI(mp3_url)

  Net::HTTP.start(uri.host, uri.port) do |http|
    request = Net::HTTP::Get.new uri

    http.request request do |response|
      FileUtils.mkdir_p './tmp'
      File.open './tmp/test.mp3', 'w' do |io|
        response.read_body do |chunk|
          io.write chunk
        end
      end
    end
  end
end

