require 'thread'

class MessageBuffer
	def initialize
		@received = []
		@semaphore = Mutex.new
	end

	def on_message message
		@semaphore.synchronize { @received << message }
	end

	def pop_all
		@semaphore.synchronize {
			result = @received
			@received = []
			result
		}
	end

	def peek
		@semaphore.synchronize {
			@received
		}
	end
end
