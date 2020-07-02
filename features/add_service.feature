@javascript
Feature: A non-admin user adds a service
  As a non-admin user
  I want to be able to create services
  So that I can display my service to the public

  Background:
    * I am logged in as a user

  Scenario: A user chooses to create a new service
    Given I am on the dashboard page
    When I choose to add a new service
    Then I should see the new service creation page

  Scenario: A user creates a new service
    Given I am on the new service creation page
    And I have entered valid service details for all pages
    When I submit the service
    Then I should see that my service is awaiting approval


