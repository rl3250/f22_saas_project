# POC: @KenXiong123

Feature: search for events by hosts
  As a event host
  So that I can create a new event
  I want to include and search on host information in events I enter

Background: events in database

  Given the following events exist:
  | title                     | host              | joined | attendee_limit | event_time              | status |
  | Go To Gym today afternoon | Alicent Hightower | 0      | 2              | 2022-10-30 00:00:00 UTC | open   |
  | Enjoy Lunch at Junzi      | Daemon Targaryen  | 1      | 2              | 2022-12-28 00:00:00 UTC | closed |
  | Lunch at Max Cafe         | Mysaria           | 3      | 2              | 2022-12-28 00:00:00 UTC | closed |

  Given the following users exist:
    | username          | password | email                     |
    | Daemon Targaryen  | dt123    | daemontargaryen@gmail.com |
    | Mysaria           | my456    | mysaria@gmail.com         |

Scenario: see all events on home page
  Given I logged in as "Alicent Hightower"
  When I go to the home page
  Then I should see all the events

Scenario: find event with host name
  Given I logged in as "Alicent Hightower"
  And I am on the home page
  When  I fill in "Search event/host/attendee name" with "Mysaria"
  And   I press "search_result"
  Then  I should be on the search result page
  And   I should see "Lunch at Max Cafe"

Scenario: find event with month filter
  Given I logged in as "Alicent Hightower"
  And I am on the home page
  When  I fill in "Search event/host/attendee name" with "Go"
  When  I select "October" from "start-month"
  And   I press "search_result"
  Then  I should be on the search result page
  And   I should see "Go To Gym today afternoon"

Scenario: find event with year filter
  Given I logged in as "Alicent Hightower"
  And I am on the home page
  When  I fill in "Search event/host/attendee name" with "Go"
  When  I select "2022" from "start-year"
  And   I press "search_result"
  Then  I should be on the search result page
  And   I should see "Go To Gym today afternoon"

Scenario: find event with date filter
  Given I logged in as "Alicent Hightower"
  And I am on the home page
  When  I fill in "Search event/host/attendee name" with "Go"
  When  I select "October" from "start-month"
  And   I select "2022" from "start-year"
  And   I press "search_result"
  Then  I should be on the search result page
  And   I should see "Go To Gym today afternoon"

Scenario: find event with status filter
  Given I logged in as "Alicent Hightower"
  And I am on the home page
  When  I fill in "Search event/host/attendee name" with "Go"
  When  I select "Open" from "status_selected"
  And   I press "search_result"
  Then  I should be on the search result page
  And   I should see "Go To Gym today afternoon"
  When  I fill in "Search event/host/attendee name" with "Lunch"
  When  I select "Closed" from "status_selected"
  And   I press "search_result"
  And   I should see "Enjoy Lunch at Junzi"
  
