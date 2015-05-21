require 'mosquitto'
require 'json'

class Distributor
	def initialize mosquitto: :no_mosquitto_set
		@publisher = mosquitto
		@publisher = Mosquitto::Client.new("config-distributor") if @publisher == :no_mosquitto_set
	end

	def post message
		@publisher.loop_start
		hash = JSON.parse(message)
		messages_to_distribute = hash.map do |label, content|
			content.to_json
		end
		@publisher.on_connect do |rc|
			messages_to_distribute.zip(hash.keys).each do |content, label|
				channel = "#{label}-config"
				@publisher.publish(nil, channel, content, Mosquitto::EXACTLY_ONCE, false)
			end
		end
		@publisher.connect("localhost", 1883, 1000)
		messages_to_distribute
	end
end
