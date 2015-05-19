Feature: distributor

	@mosquitto
	Scenario: distributing the server response accross the queue
		When the distributor is run
		Then a dns update message appears on the queue
