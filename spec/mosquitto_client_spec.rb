require 'mosquitto'
require './mosquitto_client'

class DummyMQ

	def initialize
		@connect_block = :no_connect_block_set
	end
	
	def on_connect &block
		@connect_block = block
	end

	def loop_start
	end

	def connect host, port, timeout
		@connect_block.call message_id
	end

	def subscribe mid, channel, qos
	end

	private
	def message_id
		5
	end
end

describe MosquittoClient do

	it 'can start consuming from a queue' do
		mq = DummyMQ.new
		client = MosquittoClient.new 'dns_lookups', mq
		client.listen
	end
end
