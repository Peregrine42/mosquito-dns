require 'json'

class MessageBuffer
	def initialize from: :message_queue_not_set
		@mq_client = from
		@received = []
	end

	def on_message message
		@received << message
	end

	def pop_all
		result = @received
		@received = []
		result
	end

	def buffer
		@received
	end

	def listen
		@mq_client.listen
	end
end
