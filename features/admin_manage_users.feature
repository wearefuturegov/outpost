@javascript
Feature: Admin manage users
    As an admin user
    I want to be able to manage users
    So that I can control who has access to make changes in the directory

    Background:
        Given I am logged in as an admin user 
        And there is a deactivated user
        And there is an active user

    Scenario: Viewing users 
        Given I am on the admin users page
        Then I should see all the users

    Scenario: Viewing active users
        Given I am on the admin users page
        And I visit the active users link
        Then I should see only the active users
        And the active users link should be disabled

    Scenario: Viewing deactivated users
        Given I am on the admin users page
        And I visit the deactivated users link
        Then I should see only the deactivated user
        And the deactivated users link should be disabled
