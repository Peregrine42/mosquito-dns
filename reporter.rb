require './message_buffer'
require './transmitter'

class Reporter
	attr_reader :buffer

	def initialize channel: :no_channel_set, target_uri: :no_uri_set
		@buffer = MessageBuffer.new
		@client = MosquittoClient.new(name: 'reporter', channel: channel, handler: @buffer)
		@transmitter = Transmitter.new(to: target_uri)
	end

	def listen
		@client.listen
	end

	def post
		@transmitter.post report(@buffer.pop_all)
	end

	def report messages
		messages
			.map { |message| JSON.parse(message.to_s) }
			.sort { |m1, m2| m1['server'] <=> m2['server'] }
	end
end
