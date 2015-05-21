require 'mosquitto'

class MosquittoClient
	def initialize name: 'client',
		             channel: :no_channel_set,
		             mosquitto: :no_mosquitto_set,
		             handler: :no_handler_set
		@channel = channel
		@mosquitto = mosquitto
		@mosquitto = Mosquitto::Client.new(name) if @mosquitto == :no_mosquitto_set
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

	def disconnect
		@mosquitto.disconnect
		@mosquitto.loop_stop(true)
	end
end
