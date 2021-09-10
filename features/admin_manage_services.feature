@javascript
Feature: Admin manage services
    As an admin user
    I want to be able to manage services
    So that I can keep the directory up to date

    Background:
        * I am logged in as an admin user
        * An organisation exists
        * Some options for suitability exist

    Scenario: Navigate to new service page
        Given I am on the admin services page
        When I click the add service button
        Then I should see the new service form

    Scenario: Create new service
        Given I am on the add new service page
        When I fill in the name with 'Test service'
        And I select the organisation 'Test org'
        And I fill in the suitability field with 'Autism'
        And I submit the service
        Then The service should be created

    Scenario: Edit an existing service
        Given A service exists
        And I am on the admin service page for 'Test service'
        When I fill in the suitability field with 'Learning difficulties'
        And I update the service
        Then The service should be updated
        And The service 'Test service' should have two suitabilities

    Scenario: Browse services by directory
        Given directories exist
        And 4 services exist in directory 'Family Information Service'
        And 2 services exist in directory 'Buckinghamshire Online Directory'
        When I am on the admin services page
        And I should see 'All (6)'
        Then I should see 'Family Information Service (4)'
        And I should see 'Buckinghamshire Online Directory (2)'
