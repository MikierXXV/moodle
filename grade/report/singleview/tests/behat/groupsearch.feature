@core @core_grades @gradereport_singleview @javascript
Feature: Within the singleview report, a teacher can use the group selector.
  Background:
    Given the following "courses" exist:
      | fullname | shortname | category | groupmode |
      | Course 1 | C1        | 0        | 0         |
      | Course 2 | C2        | 0        | 0         |
    And the following "users" exist:
      | username | firstname  | lastname | email                | idnumber | phone1     | phone2     | department | institution | city    | country  |
      | teacher1 | Teacher   | 1        | teacher1@example.com | t1       | 1234567892 | 1234567893 | ABC1       | ABCD        | Perth   | AU       |
      | student1 | Student   | 1        | student1@example.com | s1       | 3213078612 | 8974325612 | ABC1       | ABCD        | Hanoi   | VN       |
      | student2 | Student   | 2        | student2@example.com | s2       | 4365899871 | 7654789012 | ABC2       | ABCD        | Tokyo   | JP       |
    And the following "course enrolments" exist:
      | user     | course | role           |
      | teacher1 | C1     | editingteacher |
      | teacher1 | C2     | editingteacher |
      | student1 | C1     | student        |
      | student2 | C1     | student        |
    And the following "groups" exist:
      | name          | course | idnumber |
      | Default group | C1     | dg       |
      | Group 2       | C1     | g2       |
    And the following "group members" exist:
      | user     | group |
      | student1 | dg    |
      | student2 | g2    |
    And I am on the "Course 1" "grades > Single view > View" page logged in as "teacher1"

  Scenario: A teacher can see the 'group' search widget when exist groups in the course and "no groups" is active
    When I navigate to "View > Single view" in the course gradebook
    Then ".groupsearchwidget" "css_element" should exist
    When I click on ".groupsearchwidget" "css_element"
    And I wait until "All participants" "option_role" exists
    And I wait until "Default group" "option_role" exists
    And I wait until "Group 2" "option_role" exists

  Scenario: A teacher can't see the 'group' search widget when there aren't groups in the course and "no groups" is active
    When I am on the "Course 2" "grades > Single view > View" page logged in as "teacher1"
    And I navigate to "View > Single view" in the course gradebook
    Then ".groupsearchwidget" "css_element" should not exist
