Before('@mosquitto') do |scenario|
	#@pid = spawn 'echo "log_dest none" | mosquitto -c /dev/stdin'
	@pid = spawn 'mosquitto'
end

After('@mosquitto') do |scenario|
	@clients.each { |c| c.disconnect }
	Process.kill('QUIT', @pid)
	Process.wait
end

