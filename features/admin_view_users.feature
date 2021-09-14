@javascript
Feature: Admin view users
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
        And the all link should be highlighted
        And the sub navigation links should not be highlighted

    Scenario: Viewing active users
        Given I am on the admin users page
        And I visit the active users link
        Then I should see only the active users
        And the all link should be highlighted
        And the sub navigation active link should be highlighted
        

    Scenario: Viewing deactivated users
        Given I am on the admin users page
        And I visit the deactivated users link
        Then I should see only the deactivated user
        And the all link should be highlighted
        And the sub navigation deactivated link should be highlighted

