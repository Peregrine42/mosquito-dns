require 'mosquitto'
require './mosquitto_client'

class DummyMosquitto
	attr_reader :message_id, :channel, :qos
	
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
		@message_id, @channel, @qos = *args
		raise 'no connection set' unless @connection == :a_connection
	end
end

describe MosquittoClient do
	it 'can start consuming from a queue' do
		mq = DummyMosquitto.new
		allow(mq).to receive(:loop_start)
		client = MosquittoClient.new 'dns_lookups', mq

		expect { client.listen }.to_not raise_error
		expect(mq).to have_received(:loop_start)
		expect(mq.message_id).to eq nil
		expect(mq.channel).to eq 'dns_lookups'
		expect(mq.qos).to eq Mosquitto::EXACTLY_ONCE
	end
end
