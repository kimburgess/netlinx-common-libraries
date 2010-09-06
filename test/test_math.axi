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
 * $Id: $
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
 * Calculates the percentage error.
 *
 * @return				the percentage error (0.0 <= x <= 100.0)
 */
define_function double test_math_error(double estimate, double actual)
{
	if (is_NaN(estimate) ||
		is_NaN(actual) ||
		is_infinite(estimate) ||
		is_infinite(actual)) {
		return 0.0
	}
	return abs_value(estimate - actual) / actual * 100.0
}

/**
 * Returns an array of length TEST_MATH_ITERATIONS filled with random double
 * precision floating point values.
 *
 * @return			an array of doubles filled with random data
 */
define_function double[TEST_MATH_ITERATIONS] test_math_rand_doubles()
{
	stack_var double ret[TEST_MATH_ITERATIONS]
	stack_var long i
	stack_var char sign
	stack_var integer exp
	stack_var long hi
	stack_var long low
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		sign = random_number(2)
		exp = random_number(32) + 1008	// Just so we don't get too crazy
										// with the massive (or miniscule)
										// values at this point.
		hi = sign << 31 + exp << 20 + random_number(1 << 20)
		low = random_number(1 << 31)
		ret[i] = math_build_double(hi, low)
	}
	return ret
}

/**
 * Returns an array of length TEST_MATH_ITERATIONS filled with random single
 * precision floating point values.
 *
 * @return			an array of floats filled with random data
 */
define_function float[TEST_MATH_ITERATIONS] test_math_rand_floats()
{
	stack_var float ret[TEST_MATH_ITERATIONS]
	stack_var char sign
	stack_var char exp
	stack_var long mantissa
	stack_var long i
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		sign = random_number(2)
		exp = random_number(1 << 8)
		mantissa = random_number(1 << 23)
		ret[i] = math_build_float(sign << 31 + exp << 23 + mantissa)
	}
	return ret
}

/**
 * Returns an array of length TEST_MATH_ITERATIONS filled with random long
 * data.
 *
 * @return			an array of longs filled with random data
 */
define_function long[TEST_MATH_ITERATIONS] test_math_rand_longs()
{
	stack_var long ret[TEST_MATH_ITERATIONS]
	stack_var long i
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		ret[i] = random_number(1 << 32)
	}
	return ret
}

/**
 * Returns an array of length TEST_MATH_ITERATIONS filled with random char
 * data.
 *
 * @return			an array of chars filled with random data
 */
define_function char[TEST_MATH_ITERATIONS] test_math_rand_chars()
{
	stack_var char ret[TEST_MATH_ITERATIONS]
	stack_var long i
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		ret[i] = random_number(1 << 8)
	}
	return ret
}

/**
 * Test functionality and execution speed of the math_raw_be_to_long()
 * function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_math_raw_be_to_long()
{
	stack_var char test_data[4][TEST_MATH_ITERATIONS]
	stack_var long i

	test_data[1] = test_math_rand_chars()
	test_data[2] = test_math_rand_chars()
	test_data[3] = test_math_rand_chars()
	test_data[4] = test_math_rand_chars()

	test_start('math_raw_be_to_long()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		math_raw_be_to_long("test_data[1][i], test_data[2][i],
				test_data[3][i], test_data[4][i]")
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	return test_end()
}

/**
 * Test functionality and execution speed of the math_float_to_bits()
 * function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_math_float_to_bits()
{
	stack_var float test_data[TEST_MATH_ITERATIONS]
	stack_var long i

	test_data = test_math_rand_floats()

	test_start('math_float_to_bits()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		math_float_to_bits(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	return test_end()
}

/**
 * Test functionality and execution speed of the math_double_high_to_bits()
 * function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_math_double_high_to_bits()
{
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var long i

	test_data = test_math_rand_doubles()

	test_start('math_double_high_to_bits()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		math_double_high_to_bits(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	return test_end()
}

/**
 * Test functionality and execution speed of the math_double_low_to_bits()
 * function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_math_double_low_to_bits()
{
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var long i

	test_data = test_math_rand_doubles()

	test_start('math_double_low_to_bits()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		math_double_low_to_bits(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	return test_end()
}

/**
 * Test functionality and execution speed of the math_build_float() function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_math_build_float()
{
	stack_var long test_data[TEST_MATH_ITERATIONS]
	stack_var long i

	test_data = test_math_rand_longs()

	test_start('math_build_float()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		math_build_float(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	return test_end()
}

/**
 * Test functionality and execution speed of the math_build_double() function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_math_build_double()
{
	stack_var long test_data[2][TEST_MATH_ITERATIONS]
	stack_var long i

	test_data[1] = test_math_rand_longs()
	test_data[2] = test_math_rand_longs()

	test_start('math_build_double()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		math_build_double(test_data[1][i], test_data[2][i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	return test_end()
}

/**
 * Test functionality and execution speed of the math_rshift_double()
 * function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_math_rshift_double()
{
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var long i

	test_data = test_math_rand_doubles()

	test_start('math_rshift_double()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		math_rshift_double(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	return test_end()
}

/**
 * Test functionality and execution speed of the math_lshift_double()
 * function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_math_lshift_double()
{
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var long i

	test_data = test_math_rand_doubles()

	test_start('math_lshift_double()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		math_lshift_double(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	return test_end()
}

/**
 * Test functionality and execution speed of the is_int()
 * function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_is_int()
{
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var long i

	test_data = test_math_rand_doubles()

	test_start('is_int()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		is_int(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	// Check special cases
	test_check(is_int(-1.0) == true, 'breaks with -1.0 input')
	test_check(is_int(-1.5) == false, 'breaks iwth -1.5 input')
	test_check(is_int(0.0) == true, 'breaks with 0 input')
	test_check(is_int(0.5) == false, 'breaks with 0.5 input')
	test_check(is_int(MATH_NaN) == false, 'breaks with NaN')
	test_check(is_int(MATH_NEGATIVE_INFINITY) == true, 'breaks with -inf')
	test_check(is_int(MATH_POSITIVE_INFINITY) == true, 'breaks with +inf')

	return test_end()
}

/**
 * Test functionality and execution speed of the is_NaN() function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_is_NaN()
{
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var long i

	test_data = test_math_rand_doubles()

	test_start('is_NaN()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		is_NaN(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)


	// Check special cases
	test_check(is_NaN(MATH_NaN) == true, 'breaks with NaN')
	test_check(is_NaN(-1) == false, 'breaks on negative input')
	test_check(is_NaN(-1.5) == false, 'breaks on negative input')
	test_check(is_NaN(0) == false, 'breaks with 0 input')
	test_check(is_NaN(MATH_NEGATIVE_INFINITY) == false,
			'breaks with -inf')
	test_check(is_NaN(MATH_POSITIVE_INFINITY) == false,
			'breaks with +inf')

	return test_end()
}

/**
 * Test functionality and execution speed of the is_infinite() function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_is_infinite()
{
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var long i

	test_data = test_math_rand_doubles()

	test_start('is_infinite()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		is_infinite(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)


	// Check special cases
	test_check(is_infinite(MATH_NEGATIVE_INFINITY) == true, 'breaks with -inf')
	test_check(is_infinite(MATH_POSITIVE_INFINITY) == true, 'breaks with +inf')
	test_check(is_infinite(MATH_NaN) == false, 'breaks with NaN')
	test_check(is_infinite(-1) == false, 'breaks on negative input')
	test_check(is_infinite(-1.5) == false, 'breaks on negative input')
	test_check(is_infinite(0) == false, 'breaks with 0 input')

	return test_end()
}

/**
 * Test functionality and execution speed of the math_near() function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_math_near()
{
	stack_var double test_data[2][TEST_MATH_ITERATIONS]
	stack_var long i

	test_data[1] = test_math_rand_doubles()
	test_data[2] = test_math_rand_doubles()

	test_start('math_near()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		math_near(test_data[1][i], test_data[2][i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	// Check some random cases
	test_check(math_near(0, MATH_PRECISION) == true, 'breaks at bound')
	test_check(math_near(MATH_PRECISION, 0) == true, 'breaks at bound')
	test_check(math_near(0, MATH_PRECISION * 2) == true, 'does not function')
	test_check(math_near(MATH_PRECISION * 2, 0) == true, 'does not function')
	test_check(math_near(0, 0) == true, 'does not function')

	return test_end()
}

/**
 * Test functionality and execution speed of the ceil() function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_ceil()
{
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var long i

	test_data = test_math_rand_doubles()

	test_start('ceil()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		ceil(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	// Check some random cases
	test_check(ceil(0.0) == 0.0, 'breaks with 0')
	test_check(ceil(0.1) == 1.0, 'breaks with 0.1')
	test_check(ceil(-0.1) == -0.0, 'breaks with -0.1')
	test_check(ceil(1.0) == 1.0, 'breaks with 1.0')
	test_check(ceil(1.7) == 2.0, 'breaks with 1.7')

	return test_end()
}

/**
 * Test functionality and execution speed of the floor() function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_floor()
{
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var long i

	test_data = test_math_rand_doubles()

	test_start('floor()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		floor(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	// Check some random cases
	test_check(floor(0.0) == 0.0, 'breaks with 0')
	test_check(floor(0.1) == 0.0, 'breaks with 0.1')
	test_check(floor(-0.1) == -1.0, 'breaks with -0.1')
	test_check(floor(1.0) == 1.0, 'breaks with 1.0')
	test_check(floor(1.7) == 1.0, 'breaks with 1.7')

	return test_end()
}

/**
 * Test functionality and execution speed of the round() function.
 *
 * @return			a boolean reflecting success
 */
define_function char test_round()
{
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var long i

	test_data = test_math_rand_doubles()

	test_start('round()')

	// Check execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		round(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	// Check some random cases
	test_check(round(0.0) == 0.0, 'breaks with 0')
	test_check(round(0.1) == 0.0, 'breaks with 0.1')
	test_check(round(-0.1) == -0.0, 'breaks with -0.1')
	test_check(round(1.0) == 1.0, 'breaks with 1.0')
	test_check(round(1.7) == 2.0, 'breaks with 1.7')
	test_check(round(1.5) == 2.0, 'breaks with 1.5')

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

	test_data = test_math_rand_doubles()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		test_data[i] = abs_value(test_data[i])
	}

	test_start('sqrt()')

	// Test for execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		res[i] = sqrt(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)

	// Check for correct functionality
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		error = test_math_error(res[i] * res[i], test_data[i])
		test_check(error <= 0.0001,
				"'exceeds maximum error (x = ', ftoa(test_data[i]),
				', error = ', ftoa(error), '%)'")
		if (error > max_err) {
			max_err = error
		}
		avg_err = avg_err + error
	}
	avg_err = avg_err / TEST_MATH_ITERATIONS
	test_add_stat('max error', format('%1.3f', max_err), '%')
	test_add_stat('avg. error', format('%1.3f', avg_err), '%')

	// Check special cases
	test_check(sqrt(-1) == MATH_NaN, 'breaks with negative input')
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
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var double res[TEST_MATH_ITERATIONS]
	stack_var long i
	stack_var double error
	stack_var double avg_err
	stack_var double max_err

	test_data = test_math_rand_doubles()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		test_data[i] = abs_value(test_data[i])
	}

	test_start('fast_inv_sqrt()')

	// Test for execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		res[i] = fast_inv_sqrt(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)


	// Check for correct functionality
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		error = test_math_error(test_data[i] * test_data[i] * res[i] * res[i],
				test_data[i])
		test_check(error <= 0.35,
				"'exceeds maximum error (x = ', ftoa(test_data[i]),
				', error = ', ftoa(error), '%)'")
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
	stack_var double test_data[TEST_MATH_ITERATIONS]
	stack_var double res[TEST_MATH_ITERATIONS]
	stack_var long i
	stack_var double error
	stack_var double avg_err
	stack_var double max_err

	test_data = test_math_rand_doubles()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		test_data[i] = abs_value(test_data[i])
	}

	test_start('fast_sqrt()')

	// Test for execution speed
	test_timer_start()
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		res[i] = fast_sqrt(test_data[i])
	}
	test_timer_stop(TEST_MATH_ITERATIONS)


	// Check for correct functionality
	for (i = TEST_MATH_ITERATIONS; i; i--) {
		error = test_math_error(res[i] * res[i], test_data[i])
		test_check(error <= 0.35,
				"'exceeds maximum error (x = ', ftoa(test_data[i]),
				', error = ', ftoa(error), '%)'")
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
	test_math_raw_be_to_long()
	test_math_float_to_bits()
	test_math_double_high_to_bits()
	test_math_double_low_to_bits()
	test_math_build_float()
	test_math_build_double()
	test_math_rshift_double()
	test_math_lshift_double()
	test_is_int()
	test_is_NaN()
	test_is_infinite()
	test_math_near()
	test_ceil()
	test_floor()
	test_round()
	test_random()
	test_sqrt()
	test_fast_inv_sqrt()
	test_fast_sqrt()
	println("' '")
	println("'Math library testing complete.'")
	println("':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'")
}

#end_if