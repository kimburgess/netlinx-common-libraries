/* The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is a collection of test and code benchmarking utilities.
 *
 * The Initial Developer of the Original Code is Queensland Department of
 * Justice and Attorney-General.
 * Portions created by the Initial Developer are Copyright (C) 2010 the
 * Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Kim Burgess <kim.burgess@justice.qld.gov.au>
 *
 *
 * $Id: Math.axi 23 2010-05-12 16:29:43Z trueamx $
 * tab-width: 4 columns: 80
 */

program_name='test_utils'
#if_not_defined __NCL_LIB_TEST_UTILS
#define __NCL_LIB_TEST_UTILS


include 'io'


define_constant

long TEST_TL = 1						// timeline to user for execution
										// speed test timer


define_type

structure test_info {
	char is_active						// boolean containing test state
	char name[32]						// name of test
	long num_tests						// number of test cases checked
	long num_passed						// number test cases passed
	char stats[1024]					// misc stats associate with the test
}

define_variable

volatile test_info ncl_test


/**
 * Start a timer for use in execution speed tests.
 *
 * @return				boolean specifying successful timer creation
 */
define_function char test_timer_start()
{
	stack_var integer res
	stack_var long triggers[1]
	triggers[1] = 1000000			// This is completely arbitary as we are
	if (timeline_active(TEST_TL)) {	// only using the timeline as a timer, not
		return false				// triggering events.
    } else {
		res = timeline_create(TEST_TL,
				triggers,
				1,
				TIMELINE_RELATIVE,
				TIMELINE_REPEAT)
		return (res <> 0)
	}
}

/**
 * Stops the speed execution test timer and add the averge unit execution
 * speed to the test stats.
 *
 * @param	iterations	long containing the number of individual tests run
 * @return				double containing the avg test run time
 */
define_function double test_timer_stop(long iterations)
{
	stack_var long elapsed
	stack_var double avg_speed

	if (timeline_active(TEST_TL)) {
		timeline_pause(TEST_TL)
		elapsed = timeline_get(TEST_TL)
		timeline_kill(TEST_TL)
	}

	avg_speed = 1.0 * elapsed / iterations

	test_add_stat('avg. exec speed', format('%1.3f', avg_speed), "'ms (over ',
			itoa(iterations), ' runs)'")

	return avg_speed
}

/**
 * Init everything required when starting a test.
 *
 * @param	name		the name of the test
 */
define_function test_start(char name[])
{
	if (ncl_test.is_active == false) {
		ncl_test.is_active = true
		ncl_test.name = name
		ncl_test.num_tests = 0
		ncl_test.num_passed = 0
		ncl_test.stats = ""
		println("'Running test: ', name")
	} else {
		println("'Error starting ', name, ' test. ', ncl_test.name, 
				' already running.'")
	}
}

/**
 * Add a stat to be printed on test completion
 *
 * @param	name		a string containing the name of the test statistic
 * @param	value		a stirng containing the stat result
 * @param	units		a string containing the units the value uses
 */
define_function char test_add_stat(char name[], char value[], char units[])
{
	ncl_test.stats = "ncl_test.stats, $0D, $0A, name, ': ', value, units"
}

/**
 * End the test and print results.
 *
 * @return				boolean reflecting success status
 */
define_function char test_end()
{
	stack_var char tmp[256]

	println("'    ', itoa(ncl_test.num_passed), ' of ', 
			itoa(ncl_test.num_tests), ' tests passed'")
	while (ncl_test.stats <> "") {
		tmp = remove_string(ncl_test.stats, "$0D, $0A", 1)
		if (tmp <> "$0D, $0A") {
			if (tmp == "") {
				tmp = ncl_test.stats
				ncl_test.stats = ""
			} else {
				tmp = left_string(tmp, length_string(tmp) - 2)
			}
			println("'    ', tmp")
		}
	}
	println("' '")

	ncl_test.is_active = false

	return (ncl_test.num_passed == ncl_test.num_tests)
}

/**
 * Init everything required when starting a test.
 *
 * @param	pass		boolean statement to check
 * @param	msg			alert message if failure
 */
define_function test_check(char condition, char msg[])
{
	ncl_test.num_tests++
	if (condition == true) {
		ncl_test.num_passed++
	} else {
		println("'    ', msg")
	}
}

/**
 * Calculates the percentage error.
 *
 * @return				the percentage error (0.0 <= x <= 100.0)
 */
define_function double test_error(double estimate, double actual)
{
	return abs_value(estimate - actual) / actual * 100.0
}

#end_if