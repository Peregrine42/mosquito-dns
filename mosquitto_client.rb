class MosquittoClient
	def initialize channel, mosquitto
		@channel = channel
		@mosquitto = mosquitto
	end

	def listen
		@mosquitto.loop_start
		@mosquitto.connect("localhost", 1883, 1000)
	end

end
