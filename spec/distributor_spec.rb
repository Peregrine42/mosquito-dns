require 'rspec'
require 'json'
require './distributor'
require './spec/support/dummy_mosquitto'

describe Distributor do

	it 'can post to a message queue' do
		mos = DummyMosquitto.new
		dist = Distributor.new mosquitto: mos
		posted_messages = dist.post({
			'dns-lookups' => {
				'baz' => 'bar'
			},
			'foo-lookups' => {
				'something' => 'cool'
			}
		}.to_json)
		expect(posted_messages).to match_array [
			{'baz' => 'bar' }.to_json,
			{'something' => 'cool' }.to_json
		]
	end

end
