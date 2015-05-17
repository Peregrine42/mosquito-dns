require 'json'

class MessageBuffer
	def initialize to: 'localhost', from: Mosquitto::Client.new('reporter')
		@target_uri = to
		@mq_client = from
		@received = []

		@mq_client.on_message { |message| on_message message }
		@mq_client.on_connect { |rc| on_connect rc }
		@mq_client.on_subscribe { |mid, qos| on_subscribe }
	end

	def listen
		@mq_client.loop_start
		@mq_client.connect("localhost", 1883, 1000)
	end

	def pop_all
		result = @received
		@received = []
		result
	end

	def buffer
		@received
	end

	private
	def on_message message
		@received << message.to_s
	end

	def on_connect return_code
		@mq_client.subscribe(nil, "dns_lookup", Mosquitto::EXACTLY_ONCE)
	end

	def on_subscribe message_id, quality_of_service
	end
end
