require './message_buffer'
require './transmitter'
require './channel'

class Reporter
	attr_reader :channels

	def initialize policies: [], target_uri: :no_uri_set
		@channels = policies.map { |policy|
			buffer = MessageBuffer.new
			client = MosquittoClient.new(
				name: "#{policy.name}-receiver",
				channel: policy.name,
				handler: buffer
			)
			Channel.new(buffer: buffer, client: client, policy: policy)
		}
		@transmitter = Transmitter.new(to: target_uri)
	end

	def listen
		@channels.each(&:listen)
	end

	def disconnect
		@channels.each(&:disconnect)
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
