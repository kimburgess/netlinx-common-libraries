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
 * Stops the speed execution test timer.
 *
 * @return				long containing the time (ms) the timer was run for
 */
define_function long test_timer_stop()
{
	stack_var long elapsed
	if (timeline_active(TEST_TL)) {
		elapsed = timeline_get(TEST_TL)
		timeline_kill(TEST_TL)
	}
	return elapsed
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

/**
 * Generate a test report for a group of data which should lay between the
 * bounds of min and max.
 *
 * @param	name			name of the function undergoing testing
 * @param	results			array of doubles containing the test results
 * @param	min				minimum result value for pass condition (inclusive)
 * @param	max				maximum result value for pass condition (exclusive)
 * @param	total_time		total time (ms) it took to run all iterations
 * @return					boolean representing test pass status
 */
define_function char test_report_double_range(char name[], double results[],
		double min, double max, long total_time)
{
	stack_var long i
	stack_var long iterations
	stack_var long errs

	iterations = max_length_array(results)

	for (i = iterations; i; i--) {
		if (results[i] < min || results[i] > max) {
			errs++
		}
	}

	return test_report(name, (errs == 0), iterations, total_time, 
			"itoa(errs), ' errors'", "", "")
}

/**
 * Generates a test report for a doubles that should site within max_error of
 * the expected results.
 *
 * @param	name			name of the function undergoing testing
 * @param	results			array of doubles containing the actual results
 * @param	expected		array of doubles containing the expected results
 * @param	max_error		maximum % err for pass condition
 * @param	total_time		total time (ms) it took to run all iterations
 */
define_function char test_report_double(char name[], double results[],
		double expected[], float max_error, long total_time)
{
	stack_var long i
	stack_var long iterations
	stack_var double avg_speed
	stack_var double avg_error

	iterations = max_length_array(results)

	for (i = iterations; i; i--) {
		avg_error = avg_error + test_error(results[i], expected[i])
	}
	avg_error = avg_error / iterations

	return test_report(name, (max_error > avg_error), iterations, total_time, 
			"'avg. error ', format('%1.3f', avg_error), '%'", "", "")
}

/**
 * Outputs a test report and returns success / failure status.
 *
 * @param	name			name of the function undergoing testing
 * @param	pass			boolean indication success
 * @param	iterations		long containing the number of iterations tested
 * @param	total_time		long containing time (ms) the test ran for
 * @param	param1			misc result info
 * @param	param2			misc result info
 * @param	param3			misc result info
 * @return					boolean indicating success
 */
define_function char test_report(char name[], char pass, long iterations,
		long total_time, char param1[], char param2[], char param3[])
{
	stack_var char result[4]
	stack_var char params[200]
	stack_var double avg_speed

	switch (pass) {
		case true: result = "'PASS'"
		case false: result = "'FAIL'"
	}

	avg_speed = 1.0 * total_time / iterations

	if (param1 <> "") {
		params = "', ', param1"
	}

	select {
		active (params <> "" && param2 <> ""): {
			params = "params, ', ', param2"
		}
		active (param2 <> ""): {
			params = param2
		}
	}

	select {
		active (params <> "" && param3 <> ""): {
			params = "params, ', ', param3"
		}
		active (param3 <> ""): {
			params = param3
		}
	}

	println("result, ': ', name, ' - avg. speed ', format('%1.3f', avg_speed),
			'ms', params, ' (', itoa(iterations), ' iterations)'")

	return pass
}

#end_if