class EchoPrint
  require 'net/http'

  attr_reader :api_key

  def initialize(api_key)
    @api_key = api_key
  end

  def identify(filename)
    json = `echoprint-codegen "#{filename}"`

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri)

    request.body = json
    request['Content-Type'] = 'application/octet-stream'
    response = http.request(request)

    response.body
  end

  private
  def uri
    URI.parse("http://developer.echonest.com/api/v4/song/identify?api_key=#{api_key}")
  end
end
