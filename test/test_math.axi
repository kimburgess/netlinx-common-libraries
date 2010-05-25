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
											// test for speed testing


/**
 * Test functionality and execution speed of the math_is_whole_number() 
 * function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_math_is_whole_number()
{
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var long i
	stack_var double avg

	test_start('math_is_whole_number()')

	// Build some random test data
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		test_data[i] = random() * 100000.0
	}

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		math_is_whole_number(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)
	

	// Check special cases
	test_check(math_is_whole_number(-1) == true, 'breaks on negative input')
	test_check(math_is_whole_number(-1.5) == false, 'breaks on negative input')
	test_check(math_is_whole_number(0) == true, 'breaks with 0 input')
	test_check(math_is_whole_number(MATH_NaN) == false, 'breaks with NaN')
	test_check(math_is_whole_number(MATH_NEGATIVE_INFINITY) == true, 
			'breaks with -inf')
	test_check(math_is_whole_number(MATH_POSITIVE_INFINITY) == true,
			'breaks with +inf')

	return test_end()
}

/**
 * Test functionality and execution speed of the random() function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_random()
{
	stack_var double res[TEST_MATH_ITERATIONS]
	stack_var long i
	stack_var double avg

	test_start('random()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		res[i] = random()
	}
	test_timer_stop(TEST_MATH_ITERATIONS)
	

	// Check for correct functionality
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		avg = avg + res[i]
		test_check(res[i] > 0.0, 'exceeds lower bound')
		test_check(res[i] <= 1.0, 'exceeds upper bound')
	}
	avg = avg / TEST_MATH_ITERATIONS
	test_add_stat('avg. value', format('%1.5f', avg), '')

	return test_end()
}

/**
 * Test functionality and execution speed of the sqrt() function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_sqrt()
{
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var double res[TEST_MATH_ITERATIONS]
	stack_var long i
	stack_var double error
	stack_var double avg_err
	stack_var double max_err

	test_start('sqrt()')

	// Build some random test data
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		test_data[i] = random() * 100000.0
	}

	// Test for execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		res[i] = sqrt(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	// Check for correct functionality
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		error = test_error(res[i] * res[i], test_data[i])
		test_check(error <= 0.00001, 'exceeds maximum error')
		if (error > max_err) {
			max_err = error
		}
		avg_err = avg_err + error
	}
	avg_err = avg_err / TEST_MATH_ITERATIONS
	test_add_stat('max error', format('%1.3f', max_err), '%')
	test_add_stat('avg. error', format('%1.3f', avg_err), '%')

	// Check special cases
	test_check(sqrt(-1) == -1, 'breaks with negative input')
	test_check(sqrt(0) == 0, 'breaks with 0 input')
	test_check(sqrt(MATH_NaN) == MATH_NaN, 'breaks with NaN')
	test_check(sqrt(MATH_NEGATIVE_INFINITY) == MATH_NEGATIVE_INFINITY,
			'breaks with -inf')
	test_check(sqrt(MATH_POSITIVE_INFINITY) == MATH_POSITIVE_INFINITY,
			'breaks with +inf')

	return test_end()
}

/**
 * Test functionality and execution speed of the fast_inv_sqrt() function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_fast_inv_sqrt()
{
	stack_var float test_data[TEST_MATH_ITERATIONS]
	stack_var float res[TEST_MATH_ITERATIONS]
	stack_var long i
	stack_var double error
	stack_var double avg_err
	stack_var double max_err

	test_start('fast_inv_sqrt()')

	// Build some random test data
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		test_data[i] = type_cast(random() * 100000.0)
	}

	// Test for execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		res[i] = fast_inv_sqrt(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)


	// Check for correct functionality
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		error = test_error(test_data[i] * test_data[i] * res[i] * res[i],
				test_data[i])
		test_check(error <= 0.35, 'exceeds maximum error')
		if (error > max_err) {
			max_err = error
		}
		avg_err = avg_err + error
	}
	avg_err = avg_err / TEST_MATH_ITERATIONS
	test_add_stat('max error', format('%1.3f', max_err), '%')
	test_add_stat('avg. error', format('%1.3f', avg_err), '%')

	return test_end()
}

/**
 * Test functionality and execution speed of the fast_sqrt() function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_fast_sqrt()
{
	stack_var float test_data[TEST_MATH_ITERATIONS]
	stack_var float res[TEST_MATH_ITERATIONS]
	stack_var long i
	stack_var double error
	stack_var double avg_err
	stack_var double max_err

	test_start('fast_sqrt()')

	// Build some random test data
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		test_data[i] = type_cast(random() * 100000.0)
	}

	// Test for execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		res[i] = fast_sqrt(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)


	// Check for correct functionality
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		error = test_error(res[i] * res[i], test_data[i])
		test_check(error <= 0.35, 'exceeds maximum error')
		if (error > max_err) {
			max_err = error
		}
		avg_err = avg_err + error
	}
	avg_err = avg_err / TEST_MATH_ITERATIONS
	test_add_stat('max error', format('%1.3f', max_err), '%')
	test_add_stat('avg. error', format('%1.3f', avg_err), '%')

	return test_end()
}

/**
 * Test functionality and execution speed of the entire math library.
 */
define_function test_math()
{
	println("':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'")
	println("'Running math library test suite. This may take a while...'")
	println("' '")
	test_math_is_whole_number()
	test_random()
	test_sqrt()
	test_fast_inv_sqrt()
	test_fast_sqrt()
	println("' '")
	println("'Math library testing complete.'")
	println("':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'")
}

#end_if