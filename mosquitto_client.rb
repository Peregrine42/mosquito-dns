require 'mosquitto'

class MosquittoClient
	def initialize channel, mosquitto
		@channel = channel
		@mosquitto = mosquitto
	end

	def listen
		#@mosquitto.on_message { |message| on_message message }
		@mosquitto.on_connect { |rc| on_connect rc }
		#@mosquitto.on_subscribe { |mid, qos| on_subscribe }
		@mosquitto.loop_start
		@mosquitto.connect("localhost", 1883, 1000)
	end

	def on_message message
		@received << message.to_s
	end

	def on_connect return_code
		@mosquitto.subscribe(nil, @channel, Mosquitto::EXACTLY_ONCE)
	end

	def on_subscribe message_id, quality_of_service
	end

end
