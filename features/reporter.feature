Feature: the reporter

	Scenario: sending a report
		Given mosquitto is running
		And   there are pending results
		When  the reporter is run
		Then  the report is posted as json
