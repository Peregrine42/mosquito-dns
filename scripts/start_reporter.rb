require './reporter'
require './dns_policy'

policies = [ DNSPolicy.new ]
reporter = Reporter.new(policies: policies, target_uri: '109.159.159.157/igloo')
reporter.listen

while true do
	sleep 5
	reporter.post
end
