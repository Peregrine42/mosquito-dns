require './distributor'

Given 'there is a receiver waiting for config updates' do
	@buffer = MessageBuffer.new
	@client = MosquittoClient.new(
		name: 'receiver',
		channel: 'dns-lookups-config',
		handler: @buffer
	)
	@client.listen
end

def distributor_ready
	@buffer.peek.size == 1
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
		}
	}
	distributor = Distributor.new channel: 'dns-lookups-config'
	distributor.post @response.to_json
	begin
		Timeout::timeout(5) do
			while not distributor_ready do
				nothing
			end
		end
	rescue StandardError => e
		puts @buffer.peek.inspect
		raise e
	end
end

Then 'the receiver gets the config update' do
	expected_response = @response['dns-lookups']
	expect(@buffer.peek()[0].to_s).to eq expected_response.to_json
end
