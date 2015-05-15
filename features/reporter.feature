Feature: the reporter

	@mosquitto
	Scenario: sending a report
		Given the reporter is run
		When  there is an incoming result
		Then  the report is posted as json
