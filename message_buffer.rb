class MessageBuffer
	def initialize
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

	def peek
		@received
	end
end
