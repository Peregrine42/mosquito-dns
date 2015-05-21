require './reporter'
require './dns_policy'
require './distributor'

policies = [ DNSPolicy.new ]
reporter = Reporter.new(policies: policies, target_uri: '109.159.159.157/igloo')
reporter.listen

distributor = Distributor.new

while true do
	response = reporter.post
	distributor.post response
	sleep 5
end
