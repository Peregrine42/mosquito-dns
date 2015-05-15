require 'pty'
require 'mosquitto'
require 'net/http'
require 'uri'
require 'webmock/cucumber'
require 'json'

Before('@mosquitto') do |scenario|
	stub_request(:any, 'foo.com')
	@pid = spawn 'mosquitto'
end

After('@mosquitto') do |scenario|
	Process.kill('QUIT', @pid)
end

Given 'the reporter is run' do
	@done = false
	reader = Mosquitto::Client.new("blocking")
	reader.loop_start

	reader.on_message do |m|
		puts "Reader: relaying '#{ m.to_s }'"

		uri = URI.parse("http://foo.com/")
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Post.new(uri.request_uri)
		request.body = { "dns_lookup" => m.to_s }
		request["Content-Type"] = "application/json"
		response = http.request(request)

		@done = true
	end

	reader.on_connect do |rc|
		puts "Reader: Connected with return code #{rc}"
		reader.subscribe(3, "topic", Mosquitto::AT_MOST_ONCE)
	end

	reader.connect("localhost", 1883, 10)
end

When 'there is an incoming result' do
	publisher = Mosquitto::Client.new("blocking")
	publisher.loop_start

	publisher.on_publish do |mid|
		puts "Dummy Publisher: Published #{mid}"
		publisher.disconnect
	end

	publisher.connect("localhost", 1883, 10)

	publisher.on_connect do |rc|
		puts "Dummy Publisher: Connected with return code #{rc}"
		publisher.publish(nil, "topic", "test message", Mosquitto::AT_MOST_ONCE, true)
	end

	while not @done do
	end
end

Then 'the report is posted as json' do
	uri = URI.parse("http://foo.com/")
	expect(a_request(:post, uri).with { |req| req.body.values.include? "test message" }).to have_been_made
end
