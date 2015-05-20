class DummyMosquitto
	attr_reader :last_message_id, :last_channel, :last_qos

	def initialize
		@connection = :no_connection_set
		@connect_block = :no_connect_block_set
		@message_block = :no_message_block_set
	end

	def connect host, port, timeout
		@connection = :a_connection
		random_message_id = 5
		@connect_block.call random_message_id
	end

	def subscribe *args
		@last_message_id, @last_channel, @last_qos = *args
		raise 'no connection set' unless @connection == :a_connection
	end

	def on_message &block
		@message_block = block
	end

	def publish_fake_message message
		@message_block.call message
	end

	def loop_start
	end

	def on_message &block
		@message_block = block
	end

	def on_subscribe &block
		@subscribe_block = block
	end

	def on_connect &block
		@connect_block = block
	end

	def publish_fake_message message
		@message_block.call message
	end

	def publish *args
		@last_published = *args
	end
end

