require './message_buffer'

class DummyMQ
	def on_message &block
		@message_block = block
	end

	def on_connect &block
		@connect_block = block
	end

	def on_subscribe &block
		@subscribe_block = block
	end

	def publish_fake_message message
		@message_block.call message
	end
end

describe MessageBuffer do

	it 'buffers the message queue' do
		dummy_mq = DummyMQ.new
		reporter = MessageBuffer.new from: dummy_mq
		dummy_mq.publish_fake_message 'hi!'
		expect(reporter.buffer).to eq ['hi!']
	end

	it 'can pop all buffered messages' do
		dummy_mq = DummyMQ.new
		reporter = MessageBuffer.new from: dummy_mq
		dummy_mq.publish_fake_message 'hi!'
		dummy_mq.publish_fake_message 'there!'
		expect(reporter.pop_all).to eq ['hi!', 'there!']
		expect(reporter.buffer).to eq []
	end

end
