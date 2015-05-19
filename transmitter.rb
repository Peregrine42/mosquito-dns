require 'json'
require 'uri'
require 'net/http'
require './mosquitto_client'
require './message_buffer'

class Transmitter
	def initialize to: :no_host_set
		@host = to
	end

	def post report
		post_over_http consolidated(report), @host
	end

	def consolidated report
		{ 'dns_lookups' => report }.to_json
	end

	def post_over_http some_json, target_uri
		uri = URI.parse("http://" + target_uri)
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Post.new(uri.request_uri)
		request.body = some_json
		request["Content-Type"] = "application/json"
		response = http.request(request)
	end
end
