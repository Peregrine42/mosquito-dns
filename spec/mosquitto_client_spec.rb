require 'mosquitto'
require './mosquitto_client'
require './spec/support/dummy_mosquitto'

describe MosquittoClient do
	it 'can start consuming from a queue' do
		mq = DummyMosquitto.new
		client = MosquittoClient.new 'dns_lookups', mosquitto: mq
		allow(mq).to receive(:loop_start)

		expect { client.listen }.to_not raise_error
		expect(mq).to have_received(:loop_start)
		expect(mq.last_message_id).to eq nil
		expect(mq.last_channel).to eq 'dns_lookups'
		expect(mq.last_qos).to eq Mosquitto::EXACTLY_ONCE
	end

	it 'passes messages to a handler' do
		mq = DummyMosquitto.new
		handler = double(:handler)
		allow(handler).to receive(:on_message)
		message = double(:message)
		client = MosquittoClient.new 'dns_lookups', mosquitto: mq, handler: handler
		client.listen

		mq.publish_fake_message message

		expect(handler).to have_received(:on_message)
			.with(message)
	end
end
