require 'mosquitto'

class MosquittoClient
	def initialize channel, mosquitto
		@channel = channel
		@mosquitto = mosquitto
	end

	def listen
		@mosquitto.on_connect { |rc| on_connect rc }
		@mosquitto.loop_start
		@mosquitto.connect('localhost', 1883, 1000)
	end

	def on_connect return_code
		@mosquitto.subscribe(nil, @channel, Mosquitto::EXACTLY_ONCE)
	end
end
