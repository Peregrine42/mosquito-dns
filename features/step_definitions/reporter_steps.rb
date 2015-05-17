require 'pty'
require 'mosquitto'
require 'net/http'
require 'uri'
require 'webmock/cucumber'
require 'json'

require './reporter'

Before('@mosquitto') do |scenario|
	stub_request(:any, 'foo.com')
	#@pid = spawn 'echo "log_dest none" | mosquitto -c /dev/stdin'
	@pid = spawn 'mosquitto'
end

After('@mosquitto') do |scenario|
	Process.kill('QUIT', @pid)
end

Given /the reporter is pointed at (\S+)/ do |target_uri|
	@reporter = Reporter.new(to: target_uri)
	@reporter.listen
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

		publisher.publish(nil, 'dns_lookup', message_1, Mosquitto::EXACTLY_ONCE, false)
		publisher.publish(nil, 'dns_lookup', message_2, Mosquitto::EXACTLY_ONCE, false)
		puts "publisher sent test messages"
	end
end

def consolidated buffer
	{ 'dns_lookups' => buffer }
end

def buffer
	@received
end

def ready
	buffer.size == 2
end

def nothing
end

def post_over_http some_json, target_uri
	uri = URI.parse("http://" + target_uri)
	http = Net::HTTP.new(uri.host, uri.port)
	request = Net::HTTP::Post.new(uri.request_uri)
	request.body = some_json
	request["Content-Type"] = "application/json"
	response = http.request(request)
end

def report target_uri
	post_over_http consolidated(buffer), target_uri
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
		'dns_lookups' => [
			{ 'server' => '1.1.1.1',
				'hostname' => 'www.google.com',
				'ip_address' => '9.9.9.9' },

			{ 'server' => '1.1.1.2',
				'hostname' => 'www.google.com',
				'ip_address' => '' }
		]
	}
	expect(a_request(:post, target_uri).with { |req| 
		req.body.eql? expected_report 
	}).to have_been_made.once
end
