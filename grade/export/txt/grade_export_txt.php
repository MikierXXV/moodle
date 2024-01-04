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
require_once($CFG->libdir . '/csvlib.class.php');

class grade_export_txt extends grade_export {

    public $plugin = 'txt';

    public $separator; // default separator

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
        $this->separator = $formdata->separator;
        $this->formdata = $formdata;
        // Overrides.
        $this->usercustomfields = true;
    }

    public function get_export_params() {
        $params = parent::get_export_params();
        $params['separator'] = $this->separator;
        return $params;
    }

    public function print_grades() {
        global $CFG;

        $export_tracking = $this->track_exports();

        $strgrades = get_string('grades');
        $profilefields = grade_helper::get_user_profile_fields($this->course->id, $this->usercustomfields);

        $shortname = format_string($this->course->shortname, true, array('context' => context_course::instance($this->course->id)));
        $downloadfilename = clean_filename("$shortname $strgrades");
        $csvexport = new csv_export_writer($this->separator);
        $csvexport->set_filename($downloadfilename);

        // Obtain selected fields from user formdata.
        $profilefieldsselected = [];
        foreach ($this->formdata as $key => $data) {
            if (str_contains($key, "userfieldsvisbile_")) {
                $value = str_replace("userfieldsvisbile_", "", $key);
                array_push($profilefieldsselected, $value);
            }
        }

        // Edit fields only choosing the selected ones.
        foreach ($profilefields as $key => $fields) {
            if ($profilefieldsselected !== null && !in_array($fields->shortname, $profilefieldsselected)) {
                unset($profilefields[$key]);
            }
        }

        $exporttitle = array();

        // Check if are groups in course.
        $groups = groups_get_all_groups($this->course->id);
        $groupscourse = count($groups) >= 1;

        // Added column Groups.
        if ($groupscourse) {
            $exporttitle[] = get_string('group');
        }

        // Print names of all the fields.
        foreach ($profilefields as $field) {
            $exporttitle[] = $field->fullname;
        }

        if (!$this->onlyactive) {
            $exporttitle[] = get_string("suspended");
        }

        // Add grades and feedback columns.
        foreach ($this->columns as $gradeitem) {
            foreach ($this->displaytype as $gradedisplayname => $gradedisplayconst) {
                $exporttitle[] = $this->format_column_name($gradeitem, false, $gradedisplayname);
            }
            if ($this->export_feedback) {
                $exporttitle[] = $this->format_column_name($gradeitem, true);
            }
        }
        // Last downloaded column header.
        $exporttitle[] = get_string('timeexported', 'gradeexport_txt');
        $csvexport->add_data($exporttitle);

        // Print all the lines of data.
        $geub = new grade_export_update_buffer();
        $gui = new graded_users_iterator($this->course, $this->columns, $this->groupid);
        $gui->require_active_enrolment($this->onlyactive);
        $gui->allow_user_custom_fields($this->usercustomfields);
        $gui->init();
        while ($userdata = $gui->next_user()) {

            $exportdata = array();
            $user = $userdata->user;

            if ($groupscourse) {
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
                    $exportdata[] = $groupsname;
                }
            }

            foreach ($profilefields as $field) {
                $fieldvalue = grade_helper::get_user_field_value($user, $field);
                $exportdata[] = $fieldvalue;
            }
            if (!$this->onlyactive) {
                $issuspended = ($user->suspendedenrolment) ? get_string('yes') : '';
                $exportdata[] = $issuspended;
            }
            foreach ($userdata->grades as $itemid => $grade) {
                if ($export_tracking) {
                    $status = $geub->track($grade);
                }

                foreach ($this->displaytype as $gradedisplayconst) {
                    $exportdata[] = $this->format_grade($grade, $gradedisplayconst);
                }

                if ($this->export_feedback) {
                    $exportdata[] = $this->format_feedback($userdata->feedbacks[$itemid], $grade);
                }
            }
            // Time exported.
            $exportdata[] = time();
            $csvexport->add_data($exportdata);
        }
        $gui->close();
        $geub->close();
        $csvexport->download_file();
        exit;
    }
}


