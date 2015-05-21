Feature: distributor

	@mosquitto
	Scenario: distributing the server response accross the queue
		Given there are two receivers waiting for config updates
		 When the distributor is run
	 	 Then each receiver gets config updates
