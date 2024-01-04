<?php

// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

require_once($CFG->dirroot.'/grade/export/lib.php');

class grade_export_ods extends grade_export {

    public $plugin = 'ods';

    /** @var stdClass data from the grade export form */
    private $formdata;

    /**
     * Constructor should set up all the private variables ready to be pulled
     * @param object $course
     * @param int $groupid id of selected group, 0 means all
     * @param stdClass $formdata The validated data from the grade export form.
     */
    public function __construct($course, $groupid, $formdata) {
        parent::__construct($course, $groupid, $formdata);
        $this->formdata = $formdata;
        // Overrides.
        $this->usercustomfields = true;
    }

    /**
     * To be implemented by child classes
     */
    function print_grades() {
        global $CFG;
        require_once($CFG->dirroot.'/lib/odslib.class.php');

        $export_tracking = $this->track_exports();

        $strgrades = get_string('grades');

        $shortname = format_string($this->course->shortname, true, array('context' => context_course::instance($this->course->id)));

        // Calculate file name
        $downloadfilename = clean_filename("$shortname $strgrades.ods");
        // Creating a workbook
        $workbook = new MoodleODSWorkbook("-");
        // Sending HTTP headers
        $workbook->send($downloadfilename);
        // Adding the worksheet
        $myxls = $workbook->add_worksheet($strgrades);
        // Print names of all the fields.
        $profilefieldsuser = grade_helper::get_user_profile_fields($this->course->id, $this->usercustomfields);

        // Obtain selected fields from user formdata.
        $profilefieldsselected = [];
        foreach ($this->formdata as $key => $data) {
            if (str_contains($key, "userfieldsvisbile_")) {
                $value = str_replace("userfieldsvisbile_", "", $key);
                array_push($profilefieldsselected, $value);
            }
        }

        // Edit fields only choosing the selected ones.
        foreach ($profilefieldsuser as $key => $fields) {
            if ($profilefieldsselected !== null && !in_array($fields->shortname, $profilefieldsselected)) {
                unset($profilefieldsuser[$key]);
            }
        }

        $profilefields = [];

        // Check if are groups in course.
        $groups = groups_get_all_groups($this->course->id);
        $groupscourse = count($groups) >= 1;

        if ($groupscourse) {
            $group = new stdClass();
            $group->customid = 0;
            $group->shortname = "groups";
            $group->fullname = get_string('groups');

            $profilefields[] = $group;
        }

        foreach ($profilefieldsuser as $fields) {
            $profilefields[] = $fields;
        }

        foreach ($profilefields as $id => $field) {
            $myxls->write_string(0, $id, $field->fullname);
        }

        $pos = count($profilefields);
        if (!$this->onlyactive) {
            $myxls->write_string(0, $pos++, get_string("suspended"));
        }
        foreach ($this->columns as $gradeitem) {
            foreach ($this->displaytype as $gradedisplayname => $gradedisplayconst) {
                $myxls->write_string(0, $pos++, $this->format_column_name($gradeitem, false, $gradedisplayname));
            }

            // Add a column_feedback column.
            if ($this->export_feedback) {
                $myxls->write_string(0, $pos++, $this->format_column_name($gradeitem, true));
            }
        }
        // Last downloaded column header.
        $myxls->write_string(0, $pos++, get_string('timeexported', 'gradeexport_ods'));

        // Print all the lines of data.
        $i = 0;
        $geub = new grade_export_update_buffer();
        $gui = new graded_users_iterator($this->course, $this->columns, $this->groupid);
        $gui->require_active_enrolment($this->onlyactive);
        $gui->allow_user_custom_fields($this->usercustomfields);
        $gui->init();
        while ($userdata = $gui->next_user()) {
            $i++;
            $user = $userdata->user;

            foreach ($profilefields as $id => $field) {
                if ($field->shortname != "groups") {
                    $fieldvalue = grade_helper::get_user_field_value($user, $field);
                    $myxls->write_string($i, $id, $fieldvalue);
                } else {
                    $usergroups = groups_get_user_groups($this->course->id, $user->id);
                    $ugrs = $usergroups[0];
                    if (!empty($usergroups)) {
                        $groupsname = "";
                        $first = true;
                        foreach ($ugrs as $gr) {
                            $grname = groups_get_group($gr, "name");
                            if ($first) {
                                $groupsname = $grname->name;
                                $first = false;
                            } else {
                                $groupsname .= ',' . $grname->name;
                            }
                        }
                        $myxls->write_string($i, $id, $groupsname);
                    }
                }
            }

            $j = count($profilefields);

            if (!$this->onlyactive) {
                $issuspended = ($user->suspendedenrolment) ? get_string('yes') : '';
                $myxls->write_string($i, $j++, $issuspended);
            }
            foreach ($userdata->grades as $itemid => $grade) {
                if ($export_tracking) {
                    $status = $geub->track($grade);
                }

                foreach ($this->displaytype as $gradedisplayconst) {
                    $gradestr = $this->format_grade($grade, $gradedisplayconst);
                    if (is_numeric($gradestr)) {
                        $myxls->write_number($i, $j++, $gradestr);
                    } else {
                        $myxls->write_string($i, $j++, $gradestr);
                    }
                }

                // writing feedback if requested
                if ($this->export_feedback) {
                    $myxls->write_string($i, $j++, $this->format_feedback($userdata->feedbacks[$itemid], $grade));
                }
            }
            // Time exported.
            $myxls->write_string($i, $j++, time());
        }
        $gui->close();
        $geub->close();

        // Close the workbook.
        $workbook->close();

        exit;
    }
}


