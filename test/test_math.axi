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
 * The Original Code is a test suite for the NetLinx common libraries math
 * library.
 *
 * The Initial Developer of the Original Code is Queensland Department of
 * Justice and Attorney-General.
 * Portions created by the Initial Developer are Copyright (C) 2010 the
 * Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Kim Burgess <kim.burgess@justice.qld.gov.au>
 *
 * $Id: Math.axi 23 2010-05-12 16:29:43Z trueamx $
 * tab-width: 4 columns: 80
 */

program_name='test_math'
#if_not_defined __NCL_LIB_TEST_MATH
#define __NCL_LIB_TEST_MATH


include 'math'
include 'io'
include 'test_utils'


define_constant

long TEST_MATH_ITERATIONS = 1000			// number of times to execute each
											// test


/**
 * Test functionality and execution speed of the random() function.
 *
 * @return			a boolean reflecting success (speed and functionality)
 */
define_function char test_random()
{
	stack_var double res[TEST_MATH_ITERATIONS]
	stack_var long i
	stack_var long err_cnt
	stack_var long total_time

	// Test for execution speed
	test_timer_start()
	for (i = max_length_array(res); i; i--) {
		res[i] = random()
	}
	total_time = test_timer_stop()

	return test_report_double_range('random()', res, 0.0, 1.0, total_time)
}

/**
 * Test functionality and execution speed of the sqrt() function.
 *
 * @return			a boolean reflecting success (speed and functionality)
 */
define_function char test_sqrt()
{
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var double res[TEST_MATH_ITERATIONS]
	stack_var double tmp[TEST_MATH_ITERATIONS]
	stack_var long i
	stack_var long total_time

	for (i = max_length_array(test_data); i; i--) {
		test_data[i] = random() * 100000.0
	}

	test_timer_start()
	for (i = max_length_array(res); i; i--) {
		res[i] = sqrt(test_data[i])
	}
	total_time = test_timer_stop()

	for (i = max_length_array(res); i; i--) {
		tmp[i] = res[i] * res[i]
	}
	
	test_report_double('sqrt()', tmp, test_data, 0.001, total_time)
}


/**
 * Test functionality and execution speed of the fast_sqrt() function.
 *
 * @return			a boolean reflecting success (speed and functionality)
 */
define_function char test_fast_sqrt()
{
	stack_var float test_data[TEST_MATH_ITERATIONS]
	stack_var double res[TEST_MATH_ITERATIONS]
	stack_var double tmp[TEST_MATH_ITERATIONS]
	stack_var long i
	stack_var long total_time

	for (i = max_length_array(test_data); i; i--) {
		test_data[i] = type_cast(random() * 100000.0)
	}

	test_timer_start()
	for (i = max_length_array(res); i; i--) {
		res[i] = fast_sqrt(test_data[i])
	}
	total_time = test_timer_stop()

	for (i = max_length_array(res); i; i--) {
		tmp[i] = res[i] * res[i]
	}

	return test_report_double('fast_sqrt()', tmp, test_data, 0.2, total_time)
}

/**
 * Test functionality and execution speed of the entire math library.
 */
define_function test_math()
{
	println("'.............................................................'")
	println("'Running math library test suite. This may take a while...'")
	test_random()
	test_sqrt()
	test_fast_sqrt()
	println("'Math library testing complete.'")
	println("'.............................................................'")
}

#end_if