require './mosquitto_client'
require './message_buffer'

class Reporter
	def initialize to: :no_host_set, from: :no_buffer_set
		@host = to
		@buffer = from
	end

	def listen
		@buffer.listen
	end

	def post
		post_over_http consolidated(report), target_uri
	end

	def post_over_http some_json, target_uri
		uri = URI.parse("http://" + target_uri)
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Post.new(uri.request_uri)
		request.body = some_json
		request["Content-Type"] = "application/json"
		response = http.request(request)
	end

	def report
		@buffer.pop_all
	end
end
