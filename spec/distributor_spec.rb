require 'rspec'
require 'json'
require './distributor'
require './spec/support/dummy_mosquitto'

describe Distributor do

	it 'can post to a message queue' do
		mos = DummyMosquitto.new
		dist = Distributor.new channel: 'foo', mosquitto: mos
		posted_messages = dist.post({
			'dns-lookups' => {
				'baz' => 'bar'
			}
		}.to_json)
		expect(posted_messages).to eq [ {'baz' => 'bar' }.to_json ]
	end

end
