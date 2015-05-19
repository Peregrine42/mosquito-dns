require 'uri'
require 'net/http'
require './mosquitto_client'
require './message_buffer'

class Transmitter
	def initialize to: :no_host_set
		@host = to
	end

	def post report
		post_over_http report
	end

	def post_over_http some_json
		uri = URI.parse("http://" + @host)
		request = post_request uri, some_json
		http = Net::HTTP.new(uri.host, uri.port)
		http.request(request)
	end

	private
	def post_request uri, content
		request = Net::HTTP::Post.new(uri.request_uri)
		request.body = content
		request["Content-Type"] = "application/json"
		request
	end
end
