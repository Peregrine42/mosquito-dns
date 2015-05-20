Feature: distributor

	@mosquitto
	Scenario: distributing the server response accross the queue
		Given there is a receiver waiting for config updates
		 When the distributor is run
	 	 Then the receiver gets the config update
