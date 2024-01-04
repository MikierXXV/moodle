@core @core_grades @gradeimport_csv @javascript
Feature: Group selector behaviour within the grader import.
  Background:
    Given the following "courses" exist:
    | fullname | shortname | category | groupmode |
    | Course 1 | C1        | 0        | 0         |
    | Course 2 | C2        | 0        | 0         |
    And the following "users" exist:
    | username  | firstname | lastname  | email                 | idnumber  |
    | teacher1  | Teacher   | 1         | teacher1@example.com  | t1        |
    And the following "course enrolments" exist:
    | user      | course | role           |
    | teacher1  | C1     | editingteacher |
    | teacher1  | C2     | editingteacher |
    And the following "groups" exist:
    | name          | course | idnumber |
    | Default group | C1     | dg       |
    And I am on the "Course 1" "grades > Grader report > View" page logged in as "teacher1"

  Scenario: A teacher can see the 'group' search widget when exist groups in the course and "no groups" is active
    When I navigate to "More > Import" in the course gradebook
    Then ".singleselect" "css_element" should exist

  Scenario: A teacher can't see the 'group' search widget when there aren't groups in the course and "no groups" is active
    When I am on the "Course 2" "grades > Grader report > View" page logged in as "teacher1"
    And I navigate to "More > Import" in the course gradebook
    Then ".singleselect" "css_element" should not exist

  Scenario: A teacher can select, in the 'group' search, the Default group
    When I navigate to "View > Overview report" in the course gradebook
    Then ".singleselect" "css_element" should exist
    And I select "Default group" from the "Groups" singleselect
    Then I should see "Default group"
