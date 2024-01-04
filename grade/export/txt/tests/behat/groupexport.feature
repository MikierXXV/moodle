@gradeexport @gradeexport_txt
Feature: I need to export grades, using the group selector, as text
  In order to easily review marks
  As a teacher
  I need to have a export grades as text

  Background:
    Given the following "courses" exist:
      | fullname | shortname | category | groupmode |
      | Course 1 | C1 | 0 | 0 |
    And the following "users" exist:
      | username | firstname | lastname | email | institution | department | idnumber |
      | teacher1 | Teacher | 1 | teacher1@example.com | Moodle | Maths | 10           |
      | student1 | Student | 1 | student1@example.com | Moodle | Maths | 11           |
    And the following "course enrolments" exist:
      | user | course | role |
      | teacher1 | C1 | editingteacher |
      | student1 | C1 | student |
    And the following "activities" exist:
      | activity | course | idnumber | name | intro | assignsubmission_onlinetext_enabled |
      | assign | C1 | a1 | Test assignment name | Submit your online text | 1 |
      | assign | C1 | a2 | Test assignment name 2 | Submit your online text | 1 |
    And the following "grade grades" exist:
      | gradeitem            | user     | grade |
      | Test assignment name | student1 | 80.00 |
    And I am on the "Course 1" "grades > Grader report > View" page logged in as "teacher1"

  @javascript
  Scenario: A teacher can see the 'group' search widget when exist groups in the course and "no groups" is active
    Given the following "groups" exist:
      | name    | course | idnumber |
      | Group 1 | C1     | G1       |
    When I navigate to "Plain text file" export page in the course gradebook
    Then ".singleselect" "css_element" should exist

  @javascript
  Scenario: A teacher can't see the 'group' search widget when there aren't groups in the course and "no groups" is active
    When I navigate to "Plain text file" export page in the course gradebook
    Then ".groupsearchwidget" "css_element" should not exist

  @javascript
  Scenario: A teacher can see the 'group' search widget when there are groups in the course
    Given the following "courses" exist:
      | fullname | shortname | category | groupmode |
      | Course 2 | C2        | 0        | 1         |
    And the following "course enrolments" exist:
      | user      | course | role           |
      | teacher1  | C2     | editingteacher |
    And the following "groups" exist:
      | name    | course | idnumber |
      | Group 1 | C2     | G1       |
    And I am on the "Course 2" "grades > Grader report > View" page logged in as "teacher1"
    When I navigate to "View > Grader report" in the course gradebook
    Then ".singleselect" "css_element" should not exist

  @javascript
  Scenario: Export grades as text with a custom user field
    When I log in as "admin"
    And I navigate to "Users > Accounts > User profile fields" in site administration
    And I click on "Create a new profile field" "link"
    And I click on "Text area" "link"
    And I set the following fields to these values:
      | Short name                    | Description  |
      | Name                          | Description |
      | Default value                 | Trainee Student |
    When I click on "Save changes" "button"
    Then I should see "Description"
    Then I navigate to "Grades > General settings" in site administration
    And I set the field "Grade export custom profile fields" to "Description"
    And I click on "Save changes" "button"
    And I log out

    When I log in as "teacher1"
    And I am on "Course 1" course homepage
    Then I navigate to "Plain text file" export page in the course gradebook
    And I expand all fieldsets
    And I click on "Course total" "checkbox"
    And I set the field "Grade export decimal places" to "1"
    And I press "Download"
    Then I should see "Student,1"
    And I should see "11"
    And I should see "Moodle"
    And I should see "Maths"
    And I should see "student1@example.com"
    And I should see "Trainee Student"
    And I should see "80.0"
    And I should not see "Course total"
    And I should not see "80.00"

  @javascript
  Scenario: Export grades as text with all participants
    Given the following "users" exist:
      | username | firstname | lastname | email | institution | department | idnumber |
      | student2 | Student | 2 | student2@example.com | Moodle | Maths | 12           |
    And the following "course enrolments" exist:
      | user | course | role |
      | student2 | C1 | student |
    And the following "groups" exist:
      | name    | course | idnumber |
      | Group 1 | C1     | G1       |
      | Group 2 | C1     | G2       |
    And the following "group members" exist:
      | user        | group |
      | student1    | G1  |
      | student2    | G2  |
    When I navigate to "Plain text file" export page in the course gradebook
    And I expand all fieldsets
    And I click on "Course total" "checkbox"
    And I set the field "Grade export decimal places" to "1"
    And I press "Download"
    Then I should see "Group 1"
    And I should see "Student,1"
    And I should see "11"
    And I should see "Moodle"
    And I should see "Maths"
    And I should see "student1@example.com"
    And I should see "80.0"
    Then I should see "Group 2"
    And I should see "Student,2"
    And I should see "12"
    And I should see "Moodle"
    And I should see "Maths"
    And I should see "student2@example.com"
    And I should see "80.0"
    And I should not see "Course total"
    And I should not see "80.00"

  @javascript
  Scenario: Export grades as text with users from Group 1
    Given the following "users" exist:
      | username | firstname | lastname | email | institution | department | idnumber |
      | student2 | Student | 2 | student2@example.com | Moodle | Maths | 12           |
    And the following "course enrolments" exist:
      | user | course | role |
      | student2 | C1 | student |
    And the following "groups" exist:
      | name    | course | idnumber |
      | Group 1 | C1     | G1       |
      | Group 2 | C1     | G2       |
    And the following "group members" exist:
      | user        | group |
      | student1    | G1  |
      | student2    | G2  |
    When I navigate to "Plain text file" export page in the course gradebook
    And I select "Group 1" from the "Groups" singleselect
    And I expand all fieldsets
    And I click on "Course total" "checkbox"
    And I set the field "Grade export decimal places" to "1"
    And I press "Download"
    Then I should see "Group 1"
    And I should see "Student,1"
    And I should see "11"
    And I should see "Moodle"
    And I should see "Maths"
    And I should see "student1@example.com"
    And I should see "80.0"
    And I should not see "Group 2"

