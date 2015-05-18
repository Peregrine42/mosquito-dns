require './message_buffer'
require './transmitter'

class Reporter
	attr_reader :buffer

	def initialize channel: :no_channel_set, target_uri: :no_uri_set
		@buffer = MessageBuffer.new
		@transmitter = Transmitter.new(to: target_uri, from: @buffer)
		@client = MosquittoClient.new(name: 'reporter', channel: channel, handler: @buffer)
	end

	def listen
		@client.listen
	end

	def post
		@transmitter.post
	end
end
