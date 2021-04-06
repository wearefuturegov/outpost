@javascript
Feature: Admin manage services
    As an admin user
    I want to be able to manage services
    So that I can keep the directory up to date

    Background:
        * I am logged in as an admin user

    Scenario: Create a new service
        Given I am on the admin services page
        When I click the add service button
        Then I should see the new service form