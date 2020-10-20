
Feature: Add a new service
    As a community user
    I want to add a new service to the directory
    So that I can advertise it

    Scenario: Register and sign into the dashboard
        Given I'm registered
        And I'm at the root
        Then I should be able to sign in
        Then I should see the dashboard

        When I add a new service
        Then I can fill in fields for name and description
        Then I should reach the task list
