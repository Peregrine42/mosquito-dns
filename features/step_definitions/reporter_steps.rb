require 'pty'
require 'mosquitto'
require 'net/http'
require 'uri'
require 'webmock/cucumber'
require 'json'

Before('@mosquitto') do |scenario|
	stub_request(:any, 'foo.com')
	#@pid = spawn 'echo "log_dest none" | mosquitto -c /dev/stdin'
	@pid = spawn 'mosquitto'
end

After('@mosquitto') do |scenario|
	Process.kill('QUIT', @pid)
end

Given /the reporter is pointed at (\S+)/ do |target_uri|
	@received = []

	reporter = Mosquitto::Client.new('reporter')
	reporter.loop_start

	reporter.on_message do |message|
		puts "reporter received: #{message.to_s}"

		@received << message.to_s
		puts @received
	end

	reporter.on_connect do |rc|
		puts "reporter connected with return code #{rc}"
		reporter.subscribe(nil, "dns_lookup", Mosquitto::EXACTLY_ONCE)
	end

	reporter.on_subscribe do |mid, qos|
		puts "reporter subscribed with mid #{mid} and qos #{qos}"
	end

	reporter.connect("localhost", 1883, 1000)
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
		publisher.publish(nil, "dns_lookup", "test message", Mosquitto::EXACTLY_ONCE, false)
		publisher.publish(nil, "dns_lookup", "test message 2", Mosquitto::EXACTLY_ONCE, false)
		publisher.publish(nil, "dns_lookup", "test message 3", Mosquitto::EXACTLY_ONCE, false)
		puts "publisher sent test messages"
	end
end

def buffered
	@received
end

def ready
	buffered.sort == ["test message", "test message 2", "test message 3"]
end

When /the timer runs down/ do
	Timeout::timeout(5) do
		while not ready do end
	end
end

Then /a report is posted to (\S+) as json/ do |target_uri|

end

Given /old the reporter is pointed at (\S+)/ do |target_uri|
	@done = []
	reader = Mosquitto::Client.new("reporter")
	reader.loop_start

	reader.on_message do |m|
		puts "Reader: relaying '#{ m.to_s }'"

		uri = URI.parse("http://" + target_uri)
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Post.new(uri.request_uri)
		request.body = { "dns_lookup" => m.to_s }
		request["Content-Type"] = "application/json"
		response = http.request(request)

		@done << m.to_s
	end


	reader.on_connect do |rc|
		puts "Reader: Connected with return code #{rc}"
	end

	reader.on_subscribe do |mid, qos|
		puts "subscribed with mid #{mid} and qos #{qos}"
	end

	reader.connect("localhost", 1883, 1000)

	@reader_ready = false
	reader.on_connect do |rc|
		@reader_ready = true
	end

	Timeout::timeout(3) {
		while not @reader_ready do
		end
		reader.subscribe(nil, "dns_lookup", Mosquitto::EXACTLY_ONCE)
	}
end

When 'there is an incoming result' do
	publisher = Mosquitto::Client.new("publisher")
	publisher.loop_start

	publisher.on_publish do |mid|
		puts "Dummy Publisher: Published #{mid}"
	end

	publisher.connect("localhost", 1883, 1000)

	publisher.on_connect do |rc|
		puts "Dummy Publisher: Connected with return code #{rc}"
		publisher.publish(nil, "dns_lookup", "test message", Mosquitto::EXACTLY_ONCE, false)
		publisher.publish(nil, "dns_lookup", "test message 2", Mosquitto::EXACTLY_ONCE, false)
		publisher.publish(nil, "dns_lookup", "test message 3", Mosquitto::EXACTLY_ONCE, false)
	end

	Timeout::timeout(7) {
		while not @done.sort == ["test message", "test message 2", "test message 3"] do
		end
	}
end

Then /old a report is posted to (\S+) as json/ do |target_uri|
	uri = URI.parse(target_uri)
	expected_report = {
		'dns_lookups' => {
			'1.1.1.1' => true,
			'1.1.1.2' => true,
			'1.1.1.3' => false
		}
	}
	expect(a_request(:post, uri).with { |req| req.body.values.include? "test message" }).to have_been_made.once
	expect(a_request(:post, uri).with { |req| req.body.values.include? "test message 2" }).to have_been_made.once
	expect(a_request(:post, uri).with { |req| req.body.values.include? "test message 3" }).to have_been_made.once
end
