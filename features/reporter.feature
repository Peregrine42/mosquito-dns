Feature: the reporter

	Scenario: sending a report
		Given mosquitto is running
		And   the reporter is run
		When  there is an incoming result
		Then  the report is posted as json
