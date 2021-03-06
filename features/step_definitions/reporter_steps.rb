require 'pty'
require 'mosquitto'
require 'net/http'
require 'uri'
require 'webmock/cucumber'
require 'json'

require './reporter'
require './dns_policy'

Given /the reporter is pointed at (\S+)/ do |target_uri|
	stub_request(:any, target_uri)
	@reporter = Reporter.new(
	  policies: [ DNSPolicy.new ],
		target_uri: target_uri
	)
	@reporter.listen
	@clients = [ @reporter ]
end

Given /there are some incoming results/ do
	publisher = Mosquitto::Client.new("publisher")
	publisher.loop_start

	publisher.on_publish do |mid|
		puts "publisher published #{mid}"
	end

	publisher.connect("localhost", 1883, 1000)

	publisher.on_connect do |rc|
		puts "publisher connected with return code #{rc}"

		message_1 = {
			'server' => '1.1.1.1',
			'hostname' => 'www.google.com',
			'ip_address' => '9.9.9.9'
		}.to_json

		message_2 = {
			'server' => '1.1.1.2',
			'hostname' => 'www.google.com',
			'ip_address' => ''
		}.to_json

		publisher.publish(nil, 'dns-lookups', message_1, Mosquitto::EXACTLY_ONCE, false)
		publisher.publish(nil, 'dns-lookups', message_2, Mosquitto::EXACTLY_ONCE, false)
		puts "publisher sent test messages"
	end
end

def ready
	@reporter.channels.reduce(0) { |sum, channel| sum + channel.buffer.peek.size } == 2
end

def nothing
end

When /the timer runs down/ do
	Timeout::timeout(5) do
		while not ready do
			nothing
		end
		@reporter.post
	end
end

Then /a report is posted to (\S+) as json/ do |target_uri|
	expected_report = { 
		'dns-lookups' => [
			{ 'server' => '1.1.1.1',
				'hostname' => 'www.google.com',
				'ip_address' => '9.9.9.9' },

			{ 'server' => '1.1.1.2',
				'hostname' => 'www.google.com',
				'ip_address' => '' }
		]
	}
	expect(a_request(:post, target_uri).with { |req| 
		JSON.parse(req.body).eql? expected_report
	}).to have_been_made.once
end
