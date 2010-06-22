Feature: Enforce login requirement
	In order to secure access and ensure data privacy
	As an authorized user
	I want to gain access to the system
	
	Scenario: successful login
		Given I use the test account
		And I am the registered user kip@example.com
		And I am on the login page
		When I login with valid credentials
		Then I should be on the dashboard page
		And I should see "Login successful!"