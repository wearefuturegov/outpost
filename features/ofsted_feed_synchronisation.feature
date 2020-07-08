Feature: Synchronise outpost with Ofsted feed
  As an admin user of outpost
  I want outpost data to be synchronised with the ofsted feed
  So that I can keep the service offerings up to date

  Scenario: An Ofsted feed item field is updated
    Given a service exists with a corresponding Ofsted feed item
    And the feed item has changed in the Ofsted feed
    When outpost is synchronised with the Ofsted feed
    Then the Ofsted item should be flagged for review

  Scenario: An Ofsted feed item field is added
    Given a service exists with a corresponding Ofsted feed item
    And a feed item has been added to the Ofsted feed
    When outpost is synchronised with the Ofsted feed
    Then an Ofsted item should be added

  Scenario: An Ofsted feed item field is removed
    Given a service exists with a corresponding Ofsted feed item
    And the feed item has been removed from the Ofsted feed
    When outpost is synchronised with the Ofsted feed
    Then the Ofsted item should be removed

