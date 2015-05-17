require 'mosquitto'
require './mosquitto_client'
require './spec/support/dummy_mosquitto'

describe MosquittoClient do
	it 'can start consuming from a queue' do
		mq = DummyMosquitto.new
		allow(mq).to receive(:loop_start)
		client = MosquittoClient.new 'dns_lookups', mq

		expect { client.listen }.to_not raise_error
		expect(mq).to have_received(:loop_start)
		expect(mq.last_message_id).to eq nil
		expect(mq.last_channel).to eq 'dns_lookups'
		expect(mq.last_qos).to eq Mosquitto::EXACTLY_ONCE
	end
end
