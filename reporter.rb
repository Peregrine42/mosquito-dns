require './message_buffer'
require './transmitter'

class Reporter
	attr_reader :channels

	def initialize channels: [], target_uri: :no_uri_set
		channels.each { |channel|
			buffer = MessageBuffer.new
			client = MosquittoClient.new(
				name: "#{channel.name}-receiver",
				channel: channel.name,
				handler: buffer
			)
			channel.client = client
			channel.buffer = buffer
		}
		@channels = channels
		@transmitter = Transmitter.new(to: target_uri)
	end

	def listen
		@channels.each(&:listen)
	end

	def post
		message = @channels.each_with_object({}) { |channel, result|
			result[channel.name] = channel.pop_all
		}.to_json
		@transmitter.post message
	end

	def parse messages
		messages.map { |message| JSON.parse(message.to_s) }
	end
end
