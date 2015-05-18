require './message_buffer'

describe MessageBuffer do

	it 'buffers the message queue' do
		reporter = MessageBuffer.new
		dummy_mq = MosquittoClient.new 'a_channel', handler: reporter
		dummy_mq.on_message 'hi!'
		expect(reporter.peek).to eq ['hi!']
	end

	it 'can pop all buffered messages' do
		reporter = MessageBuffer.new
		dummy_mq = MosquittoClient.new 'a_channel', handler: reporter
		dummy_mq.on_message 'hi!'
		dummy_mq.on_message 'there!'
		expect(reporter.pop_all).to eq ['hi!', 'there!']
		expect(reporter.peek).to eq []
	end

end
