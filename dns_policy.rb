require 'json'

class DNSPolicy
	def name
		'dns-lookups'
	end

	def apply messages
		messages.map { |m|
			JSON.parse(m)
		}.sort { |m1, m2| m1['server'] <=> m2['server'] }
	end
end

