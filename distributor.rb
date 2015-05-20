require 'mosquitto'

class Distributor
	def initialize channel: :no_channel_set, mosquitto: :no_mosquitto_set
		@channel = channel
		@publisher = mosquitto
		@publisher = Mosquitto::Client.new("publisher") if @publisher == :no_mosquitto_set
		@publisher.loop_start
	end

	def post message
		split_message = JSON.parse(message)['dns-lookups'].to_json
		@publisher.on_connect do |rc|
			@publisher.publish(nil, channel, split_message, Mosquitto::EXACTLY_ONCE, false)
		end
		@publisher.connect("localhost", 1883, 1000)
		[ split_message ]
	end

	private
	def channel
		@channel
	end
end
