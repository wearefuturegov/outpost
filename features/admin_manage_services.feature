@javascript
Feature: Admin manage services
    As an admin user
    I want to be able to manage services
    So that I can keep the directory up to date

    Background:
        * I am logged in as an admin user
        * An oranisation exists
        * Some options for suitability exist

    Scenario: Navigate to new service page
        Given I am on the admin services page
        When I click the add service button
        Then I should see the new service form

    Scenario: Create new service
        Given I am on the add new service page
        When I fill in the name
        #And I select the organisation
        And I fill in the suitability field
        And I submit the service
        Then The service should be created
