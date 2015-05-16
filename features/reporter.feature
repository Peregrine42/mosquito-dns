Feature: the reporter

	@mosquitto
	Scenario: sending a report
		Given the reporter is pointed at foo.com
		  And there are some incoming results
		 When the timer runs down 
		 Then a report is posted to foo.com as json
