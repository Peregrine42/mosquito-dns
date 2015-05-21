require './distributor'

Given 'there are two receivers waiting for config updates' do
	channels = ['dns-lookups', 'foo-lookups']
	@buffers = channels.map { MessageBuffer.new }
	@clients = channels.zip(@buffers).map do |channel, buffer|
			client = MosquittoClient.new(
				name: "#{channel}-receiver",
				channel: "#{channel}-config",
				handler: buffer
			)
			client.listen
			client
	end
end

def distributor_ready
	@buffers[0].peek.size == 1 && @buffers[1].peek.size == 1
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
	Timeout::timeout(5) do
		distributor = Distributor.new
		distributor.post @response.to_json
		while not distributor_ready do
			nothing
		end
	end
end

Then 'each receiver gets config updates' do
	expected_response = @response['dns-lookups']
	expect(@buffers[0].peek()[0].to_s).to eq expected_response.to_json

	expected_foo_response = @response['foo-lookups']
	expect(@buffers[1].peek()[0].to_s).to eq expected_foo_response.to_json

end
