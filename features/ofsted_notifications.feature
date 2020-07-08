@javascript
Feature: Be notified of ofsted changes
  As an admin user of outpost
  I want to be aware of new or changed ofsted information that relates to services
  So that I can keep the service offerings up to date

  Background:
    * I am logged in as an ofsted admin user

  Scenario: An Ofsted feed item field is updated
    Given a service exists with a corresponding Ofsted feed item
    And the feed item has changed in the Ofsted feed
    When outpost is synchronised with the Ofsted feed
    And I navigate to the ofsted feed
    Then I should see the updated ofsted item in the list

  Scenario: An Ofsted feed item field is added
    Given a service exists with a corresponding Ofsted feed item
    And a feed item has been added to the Ofsted feed
    When outpost is synchronised with the Ofsted feed
    And I navigate to the ofsted feed
    Then I should see the added ofsted item in the list

  Scenario: An Ofsted feed item field is removed
    Given a service exists with a corresponding Ofsted feed item
    And the feed item has been removed from the Ofsted feed
    When outpost is synchronised with the Ofsted feed
    And I navigate to the ofsted feed
    Then I should see the removed ofsted item in the list