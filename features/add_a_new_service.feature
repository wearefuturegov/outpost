
Feature: Add a new service
    As a community user
    I want to add a new service to the directory
    So that I can advertise it

    Scenario: Register and sign into the dashboard
        Given I'm registered
        And I'm at the root
        And There are options for suitability
        Then I should be able to sign in
        Then I should see the dashboard

        When I add a new service
        Then I can fill in fields for name and description
        Then I should reach the task list

        Given I can fill in website and social media fields
        Given I can fill in visibility dates

        #Given I can choose categories
        Given I can create opening times
        Given I can create fees
        Given I can create locations
        Given I can create contacts
        Given I can set ages

        Given I can answer local offer questions
        Given I can answer suitability questions
        Given I can answer extra questions

        Then I can submit my service
        And I see it pending on the dashboard