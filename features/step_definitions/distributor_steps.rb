Given 'there is a dns script' do

end

When 'the distributor is run' do
	response = {
		'dns-lookups' => {
			'checks' => [
				{ 'server' => '1.1.1.1', 'host' => 'www.google.com' },
				{ 'server' => '2.2.2.2', 'host' => 'www.bbc.co.uk' },
				{ 'server' => '1.1.1.1', 'host' => 'www.google.com' },
				{ 'server' => '2.2.2.2', 'host' => 'www.bbc.co.uk' },
			]
		}
	}
	Distributor.send response
end

Then 'a dns update message appears on the queue' do

end
