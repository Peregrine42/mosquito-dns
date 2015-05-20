require './distributor'

Given 'there are two receivers waiting for config updates' do
	channels = ['dns-lookups', 'foo-lookups']
	@buffers = channels.map { MessageBuffer.new }
	@clients = channels.zip(@buffers).map do |channel, buffer|
		MosquittoClient.new(
			name: "#{channel}-receiver",
			channel: "#{channel}-config",
			handler: buffer
		)
	end
	@clients.each { |c| c.listen }
end

def distributor_ready
	result = @buffers.reduce(0) { |sum, buffer| sum + buffer.peek.size }
	puts result
	result == 2
end

def nothing
end

When 'the distributor is run' do
	@response = {
		'dns-lookups' => {
			'checks' => [
		 		{ 'server' => '1.1.1.1', 'host' => 'www.google.com' },
				{ 'server' => '2.2.2.2', 'host' => 'www.bbc.co.uk' },
				{ 'server' => '1.1.1.1', 'host' => 'www.google.com' },
				{ 'server' => '2.2.2.2', 'host' => 'www.bbc.co.uk' },
			]
		},
		'foo-lookups' => {
			'something' => 'foo-like'
		}
	}
	distributor = Distributor.new
	distributor.post @response.to_json
	begin
		Timeout::timeout(5) do
			puts 'timer started'
			while not distributor_ready do
				nothing
			end
		end
	rescue StandardError => e
		@buffers.each { |b| puts b.peek.inspect }
		raise e
	end
end

Then 'each receiver gets config updates' do
	expected_response = @response['dns-lookups']
	expect(@buffers[0].peek()[0].to_s).to eq expected_response.to_json

	expected_foo__response = @response['foo-lookups']
	expect(@buffers[1].peek()[0].to_s).to eq expected_foo_response.to_json
end
