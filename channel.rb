class Channel
	attr_accessor :buffer, :client

	def initialize buffer: :no_buffer_set, client: :no_client_set, policy: :no_policy_set
		@buffer = buffer
		@client = client
		@policy = policy
	end

	def listen
		@client.listen
	end

	def pop_all
		@policy.apply(@buffer.pop_all.map(&:to_s))
	end

	def name
		@policy.name
	end
end

