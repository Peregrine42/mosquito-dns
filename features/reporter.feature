Feature: the reporter

	@mosquitto
	Scenario: sending a report
		Given the reporter is pointed at foo.com
		When  there is an incoming result
		Then  a report is posted to foo.com as json
