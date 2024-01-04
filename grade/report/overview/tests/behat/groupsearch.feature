@gradereport @gradereport_overview
Feature: Group searching functionality within the grader overview.
  Background:
    Given the following "courses" exist:
      | fullname | shortname | category | groupmode |
      | Course 1 | C1        | 0        | 0         |
    And the following "users" exist:
      | username  | firstname | lastname  | email                 | idnumber  |
      | teacher1  | Teacher   | 1         | teacher1@example.com  | t1        |
      | student1  | Student   | 1         | student1@example.com  | s1        |
      | student2  | Student   | 2         | student2@example.com  | s2        |
    And the following "course enrolments" exist:
      | user      | course | role           |
      | teacher1  | C1     | editingteacher |
      | student1  | C1     | student        |
      | student2  | C1     | student        |
    And the following "groups" exist:
      | name          | course | idnumber |
      | Default group | C1     | dg       |
      | Group 2       | C1     | g2       |
    And the following "group members" exist:
      | user     | group |
      | student1 | dg    |
      | student2 | g2    |
    And I am on the "Course 1" "grades > Grader report > View" page logged in as "teacher1"

  @javascript
  Scenario: A teacher can see the 'group' search widget when exist groups in the course and "no groups" is active
    When I navigate to "View > Overview report" in the course gradebook
    Then ".singleselect" "css_element" should exist

  @javascript
  Scenario: A teacher can see the 'group' search using the group filter for the student1 in Default group
    When I navigate to "View > Overview report" in the course gradebook
    Then ".singleselect" "css_element" should exist
    And I select "Default group" from the "Groups" singleselect
    And I select "Student 1" from the "Select a user" singleselect
    Then I should see "Student 1"
    And I should not see "Student 2"

  @javascript
  Scenario: A teacher can see the 'group' search using the group filter for the student2 in Group 2
    When I navigate to "View > Overview report" in the course gradebook
    Then ".singleselect" "css_element" should exist
    And I select "Group 2" from the "Groups" singleselect
    And I select "Student 2" from the "Select a user" singleselect
    Then I should see "Student 2"
    And I should not see "Student 1"

  @javascript
  Scenario: A teacher can't see the 'group' search widget when there aren't groups in the course and "no groups" is active
    Given the following "courses" exist:
      | fullname | shortname | category | groupmode |
      | Course 2 | C2        | 0        | 0         |
    And the following "course enrolments" exist:
      | user      | course | role           |
      | teacher1  | C2     | editingteacher |
    And I am on the "Course 2" "grades > Grader report > View" page logged in as "teacher1"
    When I navigate to "View > Grader report" in the course gradebook
    Then ".singleselect" "css_element" should not exist
