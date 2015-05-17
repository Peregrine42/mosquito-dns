require 'mosquitto'
require './mosquitto_client'

describe MosquittoClient do

	it 'can start consuming from a queue' do
		mq = double(:dummy_mq, loop_start: true, connect: true)
		client = MosquittoClient.new 'dns_lookups', mq
		client.listen
		expect(mq).to have_received(:loop_start)
		expect(mq).to have_received(:connect).with("localhost", 1883, 1000)
		expect(mq).to have_received(:subscribe)
		  .with(nil, "dns_lookups", Mosquitto::EXACTLY_ONCE)
	end
end
