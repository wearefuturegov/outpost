@javascript
Feature: Using service custom fields
  As an admin user
  I want to be able to manage custom fields
  So that I can customise my service directory

  Background:
    Given I am logged in as a user manager admin user 
    And there is an existing custom field section
    And there is a service called 'Hotdog stand'

  Scenario: Creating custom fields
    When I go to edit the custom field section

    When I add a new custom field
    * I can fill in the field for label with 'Custom date'
    * I can select the custom field type as 'Date'
    * I save my changes

    When I visit the edit service page for 'Hotdog stand' 
    Then I can see a 'date' type field called 'Custom date'
    And I can fill in the 'Custom date' field with '2021-09-01'
    When I save my changes
    Then I can see a 'date' type field called 'Custom date' with a value of '2021-09-01'
