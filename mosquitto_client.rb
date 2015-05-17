require 'mosquitto'

class MosquittoClient
	def initialize channel, mosquitto=:no_mq_set, handler=:no_hander_set
		@channel = channel
		@mosquitto = mosquitto
		@handler = handler
	end

	def listen
		@mosquitto.on_connect { |return_code| on_connect return_code }
		@mosquitto.on_message { |message| on_message message }
		@mosquitto.loop_start
		@mosquitto.connect('localhost', 1883, 1000)
	end

	def on_connect return_code
		@mosquitto.subscribe(nil, @channel, Mosquitto::EXACTLY_ONCE)
	end

	def on_message message
		@handler.on_message message
	end
end
