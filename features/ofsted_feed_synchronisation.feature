Feature: Synchronise outpost with Ofsted feed
  As an admin user of outpost
  I want to be aware of new or changed ofsted information that relates to services
  So that I can keep the service offerings up to date

  Scenario: An Ofsted feed item field is updated
    Given a service exists with a corresponding Ofsted feed item
    And the feed item has changed
    When outpost is synchronised with the Ofsted feed
    Then the Ofsted item should be flagged for review