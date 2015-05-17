class DummyMosquitto
	attr_reader :last_message_id, :last_channel, :last_qos
	
	def initialize
		@connection = :no_connection_set
	end

	def on_connect &block
		@connect_block = block
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
end

