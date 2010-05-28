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
 * The Original Code is a math library to expand on the base math
 * functionality provided by the NetLinx language.
 *
 * The Initial Developer of the Original Code is Queensland Department of
 * Justice and Attorney-General.
 * Portions created by the Initial Developer are Copyright (C) 2010 the
 * Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Kim Burgess <kim.burgess@justice.qld.gov.au>
 *
 * $Id$
 * tab-width: 4 columns: 80
 */

program_name='math'
#if_not_defined __NCL_LIB_MATH
#define __NCL_LIB_MATH


define_constant
double MATH_E = 2.718281828459045
double MATH_PI = 3.141592653589793

// Precision required for processor intensive math functions. If accuracy is
// not integral to their use this may be increased to improve performance.
double MATH_PRECISION = 1.0e-13


define_variable
// Psuedo constants for non-normal numbers - these are injected with their
// relevant bit patterns on boot
volatile double MATH_NaN
volatile double MATH_POSITIVE_INFINITY
volatile double MATH_NEGATIVE_INFINITY
volatile double MATH_TWO_52


/**
 * Load 4 bytes of big endian data contained in a character array into a long.
 *
 * Note: Array position 1 should contain MSB.
 *
 * @param	x		a 4 byte character array containg the data to load
 * @return			a long filled with the passed data
 */
define_function long math_raw_be_to_long(char x[4])
{
    return x[1] << 24 + x[2] << 16 + x[3] << 8 + x[4]
}

/**
 * Load a float value's IEEE 754 bit pattern into a long.
 *
 * @param	x		the float to load
 * @return			a long filled with the IEEE 754 bit pattern of the float
 */
define_function long math_float_to_bits(float x)
{
    return math_raw_be_to_long(raw_be(x))
}

/**
 * Load the raw data stored in bits 63 - 32 of a DOUBLE into a LONG.
 *
 * @param	x		the double to load
 * @return			a long filled binary data stored in the high DWord of the double
 */
define_function long math_double_high_to_bits(double x)
{
    stack_var char raw[8]
    raw = raw_be(x)
    return math_raw_be_to_long("raw[1], raw[2], raw[3], raw[4]")
}

/**
 * Load the raw data stored in bits 31 - 0 of a DOUBLE into a LONG.
 *
 * @param	x		the double to load
 * @return			a long filled binary data stored in the low DWord of the double
 */
define_function long math_double_low_to_bits(double x)
{
    stack_var char raw[8]
    raw = raw_be(x)
    return math_raw_be_to_long("raw[5], raw[6], raw[7], raw[8]")
}

/**
 * Build a float using a IEEE754 bit pattern stored in a long.
 *
 * @param	x		a long containg the raw data
 * @return			a float built from the passed data
 */
define_function float math_build_float(long x)
{
    stack_var char serialized[6]
    stack_var float ret
    serialized = "$E3, raw_be(x)"
    string_to_variable(ret, serialized, 1)
    return ret
}

/**
 * Build a double using the binary info stored across two longs. It is assumed
 * that the data is stored as per the IEEE754 standard.
 *
 * @param	hi		a long containg bits 63 - 32
 * @param	low		a long containing bits 31 - 0
 * @return			a double built from the passed data
 */
define_function double math_build_double(long hi, long low)
{
    stack_var char serialized[10]					// For some reason the buffer
    stack_var double ret							// passed to string_to_variable()
    serialized = "$E4, raw_be(hi), raw_be(low)"		// has to have an extra trailing byte
    string_to_variable(ret, serialized, 1)
    return ret
}

/**
 * Right shift (>>) a double 1 bit.
 *
 * @todo			allow for shift by an arbitary number of bits
 * @param	x		the double to shift
 * @return			the passed value >> 1
 */
define_function double math_rshift_double(double x)
{
	stack_var long hi
	stack_var long low
	hi = math_double_high_to_bits(x)
	low = math_double_low_to_bits(x)
    low = low >> 1 + (hi & 1) << 15
    hi = hi >> 1
	return math_build_double(hi, low)
}

/**
 * Left shift (<<) a double 1 bit.
 *
 * @todo			allow for shift by an arbitary number of bits
 * @param	x		the double to shift
 * @return			the passed value << 1
 */
define_function double math_lshift_double(double x)
{
	stack_var long hi
	stack_var long low
	hi = math_double_high_to_bits(x)
	low = math_double_low_to_bits(x)
    hi = (hi & $7FFFFFFF) << 1 + (low & $80000000) >> 15
    low = (low & $7FFFFFFF) << 1
	return math_build_double(hi, low)
}

/**
 * Returns true if the argument has no decimal component, otherwise returns
 * false. +/-Inf and 0 will return true, subnormal and NaN's will return
 * false.
 *
 * @param	x		the double to check
 * @return			a boolean, true if x is a mathematical integer
 */
define_function char is_int(double x)
{
	stack_var char i
	stack_var sinteger exp
	stack_var long hi
	stack_var long m
	stack_var long mask
	if (is_NaN(x)) {
		return false
	}
	if (x >= MATH_TWO_52) {
		return true
	}
	if (abs_value(x) < 1.0) {
		return (abs_value(x) == 0)
	}
	hi = math_double_high_to_bits(x)
	exp = type_cast((hi & $7FF00000) >> 20 - 1023)
	if (exp > 20) {
		m = math_double_low_to_bits(x)
	} else {
		m = hi & $FFFFF
	}
	for (i = type_cast(32 + (exp > 20) * 20 - exp); i; i--) {
		mask = mask + 1 << (i - 1)
	}
	return (m & mask == 0)
}

/**
 * Checks if a value is NaN.
 *
 * @param	x		a double to check
 * @return			a boolean, true is x is NaN
 */
define_function char is_NaN(double x)
{
	stack_var long hi
	hi = math_double_high_to_bits(x)
	return (hi & $7FF00000) >> 20 == $7FF &&
			(hi & $FFFFF || math_double_low_to_bits(x))
}

/**
 * Checks if a value is either positive infinity or negative infinity.
 *
 * @param	x		a double to check
 * @return			a boolean, true is x is infinite
 */
define_function char is_infinite(double x)
{
    stack_var long hi
	hi = math_double_high_to_bits(x)
	return (hi & $7FF00000) >> 20 == $7FF &&
			!(hi & $FFFFF || math_double_low_to_bits(x))
}

/**
 * Compares two numbers and return true if they are within MATH_PRECISION of
 * each other.
 *
 * @param	x		a number to compare
 * @param	y		another number to compare to x
 * @return			a boolean specifying if x and y are within MATH_PRECISION
 *					of each other
 */
define_function char math_near(double x, double y)
{
	return abs_value(x - y) <= MATH_PRECISION
}

/**
 * Returns the smallest (closest to negative infinity) long value that is not
 * less than the argument and is equal to a mathematical integer.
 *
 * @param	x		the double to round
 * @return			a double containing the rounded number
 */
define_function double ceil(double x)
{
    return -floor(-x)
}

/**
 * Returns the largest (closest to positive infinity) long value that is not
 * greater than the argument and is equal to a mathematical integer.
 *
 * @todo			remove dependancy on type_cast'ing to a slong to allow for
 *					correct operation over all possible inputs
 * @param	x		a double to round
 * @return			a double containing the rounded number
 */
define_function double floor(double x)
{
	stack_var double tmp
	stack_var slong ret
	tmp = abs_value(x)
	if (is_int(tmp)) {
		return x
	}
	if (tmp < 1) {
		if (x >= 0) {
			return 0.0 * x
		} else {
			return -1.0
		}
	}
	if (x < 0) {
		ret = type_cast(x - 1.0)
	} else {
		ret = type_cast(x)
	}
	return ret
}

/**
 * Rounds a flouting point number to it's closest whole number.
 *
 * @param	x		a double to round
 * @return			a double containing the rounded number
 */
define_function double round(double x)
{
    return floor(x + 0.5)
}

/**
 * Computes the remainder operation on two arguments as prescribed by the
 * IEEE 754 standard.
 *
 * @param	x		a dividend
 * @param	y		a divisor
 * @return			a double equal to x - (y Q), where Q is the quotient of
 *					x / y rounded to the nearest integer (if y = 0, NaN is
 *					returned
 */
define_function double IEEEremainder(double x, double y)
{
	if (y == 0) {
		return MATH_NaN
	}
	return x - y * round(x / y)
}

/**
 * Returns a double value with a positive sign, greater than or equal to 0.0
 * and less than 1.0.
 *
 * @return			a pseudorandom double greater than or equal to 0.0 and
 *					less than 1.0
 */
define_function double random()
{
	stack_var char i
	stack_var long hi
	stack_var long low
	for (i = 32; i; i--) {
		low = low + random_number(2) << (i - 1)
	}
	for (i = 20; i; i--) {
		hi = hi + random_number(2) << (i - 1)
	}
	hi = hi + 1023 << 20
	return math_build_double(hi, low) - 1
}

/**
 * Calculate the square root of the passed number.
 *
 * This function takes a log base 2 approximation then iterates a Babylonian
 * refinement until the answer is within the math libraries defined precision
 * or exceeds 1000 steps of refinement.
 *
 * @todo			re-write to allow for accurate (and faster) operation on
 *					small (< 1.0e-5) input values
 * @param	x		the double to find the square root of
 * @return			a double containing the square root
 */
define_function double sqrt(double x)
{
	stack_var long hi
	stack_var long low
	stack_var double i
    stack_var double tmp
	if (x < 0) {
		return MATH_NaN
	}
	if (x == 0 ||
		x == 1 ||
		is_NaN(x) ||
		is_infinite(x)) {
		return x
	}
	tmp = math_rshift_double(x)
	hi = 1 << 29 + math_double_high_to_bits(tmp) - 1 << 19
	low = math_double_low_to_bits(tmp)
	tmp = math_build_double(hi, low)
	while (!math_near(tmp * tmp, x) && i < 1000) {
		tmp = 0.5 * (tmp + x / tmp)
		i++
	}
	return tmp
}

/**
 * Approximate the inverse square root of the passed number.
 *
 * This method uses a integer shift and single Newton refinement aka Quake 3
 * method. Original algorithm by Greg Walsh.
 *
 * @param	x		the double to find the inverse square root of
 * @return			a double containing an approximation of the inverse square root
 */
define_function double fast_inv_sqrt(double x)
{
	stack_var long hi
	stack_var long low
    stack_var long t_hi
	stack_var long t_low
    stack_var double res
	stack_var double tmp
	tmp = math_rshift_double(x)
	t_hi = math_double_high_to_bits(tmp)
	t_low = math_double_low_to_bits(tmp)
	hi = $5FE6EC85 - t_hi
	if (t_low > $E7DE30DA) {
		hi = hi - (t_low - $E7DE30DA)
		low = 0
	} else {
		low = $E7DE30DA - t_low
	}
    res = math_build_double(hi, low)
    return res * (1.5 - 0.5 * x * res * res)
}

/**
 * Approximate the square root of the passed number based on the inverse square
 * root algorithm in fast_inv_sqrt(x). This is MUCH faster than sqrt(x) and
 * recommended over sqrt() for use anywhere a precise square root is not
 * required. Error is approx +/-0.17%.
 *
 * @param	x		the double to find the square root of
 * @return			a double containing an approximation of the square root
 */
define_function double fast_sqrt(double x)
{
    return x * fast_inv_sqrt(x)
}

/**
 * Calcultate the logarithm of the passed number in the specified base.
 *
 * @param	x		the float to find the log of
 * @param	base	the base to use
 * @return			a float containing the passed numbers logarithm
 */
define_function float math_log(float x, float base)
{
    stack_var float tmp
    stack_var integer int
    stack_var float partial
    stack_var float decimal
    if (x < 1 && base < 1) {
		return -1.0	// cannot compute
    }
    tmp = x + 0.0
    while (tmp < 1) {
		int = int - 1
		tmp = tmp * base
    }
    while (tmp >= base) {
		int = int + 1
		tmp = tmp / base
    }
    partial = 0.5
    tmp = tmp * tmp
    while (!math_near(partial, 0)) {
		if (tmp >= base) {
			decimal = decimal + partial
			tmp = tmp / base
		}
		partial = partial * 0.5
		tmp = tmp * tmp
    }
    return int + decimal
}

/**
 * Calcultate the natural logarithm of the passed number.
 *
 * @param	x		the float to find the natural log of
 * @return			a float containing the passed numbers log base e
 */
define_function float math_ln(float x)
{
    return math_log(x, MATH_E)
}

/**
 * Calcultate the binary logarithm of the passed number.
 *
 * @param	x		the float to find the natural log of
 * @return			a float containing the passed numbers log base 2
 */
define_function float math_log2(float x)
{
    return math_log(x, 2)
}

/**
 * Calcultate the base 10 logarithm of the passed number.
 *
 * @param	x		the float to find the natural log of
 * @return			a float containing the passed numbers log base 10
 */
define_function float math_log10(float x)
{
    return math_log(x, 10)
}

/**
 * Calcultate x raised to the n.
 *
 * @param	x		the float to find the natural log of
 * @param	n		the power to raise x to
 * @return			a float containing the x^n
 */
define_function float math_power(float x, integer n)
{
    stack_var float result
    stack_var float base
    stack_var integer exp
    result = 1.0
    base = x + 0.0
    exp = n + 0
    while (exp > 0) {
		if (exp & 1) {
			result = result * base
			exp = exp - 1
		}
		base = base * base
		exp = type_cast(round(exp * 0.5))
    }
    return result
}


DEFINE_START

MATH_NaN = math_build_double($7FFFFFFF, $FFFFFFFF)
MATH_POSITIVE_INFINITY = math_build_double($7FF00000, $00000000)
MATH_NEGATIVE_INFINITY = math_build_double($FFF00000, $00000000)
MATH_TWO_52 = 1 << 52

#end_if