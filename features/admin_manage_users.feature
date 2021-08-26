@javascript
Feature: Managing users

    Background:
        Given there is a community user called 'Mr User'

    Scenario: Superadmin manage community users
        Given I am logged in as a superadmin user
        When I visit the user page for Mr User
        * I should see an unchecked field for 'User can manage services'
        * I should see an unchecked field for 'User can see Ofsted feed'
        * I should see an unchecked field for 'User can manage other users, taxonomies and custom fields'

    Scenario: User manager admin cannot edit Ofsted access
        Given I am logged in as a user manager admin user
        When I visit the user page for Mr User
        * I should see an unchecked field for 'User can see Ofsted feed' that is disabled
        * I should see an unchecked field for 'User can manage services'
        * I should see an unchecked field for 'User can manage other users, taxonomies and custom fields'
