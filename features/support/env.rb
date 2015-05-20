Before('@mosquitto') do |scenario|
	#@pid = spawn 'echo "log_dest none" | mosquitto -c /dev/stdin'
	@pid = spawn 'mosquitto -v'
end

After('@mosquitto') do |scenario|
	Process.kill('QUIT', @pid)
	Process.wait
end

