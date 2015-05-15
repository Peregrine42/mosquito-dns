Given 'mosquitto is running' do
	require 'pty'
	begin
		cmd = "mosquitto"
		PTY.spawn(cmd) do |stdout, stdin, pid|
			@pid = pid
			begin
				stdout.each { |line| puts "#{cmd} " + line; break if line.include?("Opening ipv6 listen socket") }
			rescue Errno::EIO
			end
		end
	rescue PTY::ChildExited
		puts "The child process exited!"
	end
end

Given 'there are pending results' do

end

When 'the reporter is run' do

end

Then 'the report is posted as json' do
	Process.kill('QUIT', @pid)
end
