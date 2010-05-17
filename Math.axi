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
    stack_var char byte
    stack_var long bits
    FOR (byte = 4; byte; byte--) {
		bits = bits + (x[byte] << ((4 - byte) << 3))
    }
    return bits
}

/**
 * Load a signed long's bit pattern into a long.
 *
 * @param	x		the slong to load
 * @return			a long filled with the bit pattern of the slong
 */
define_function long math_slong_to_bits(slong x)
{
    return math_raw_be_to_long(raw_be(x))
}

/**
 * Load a float value's IEEE 754 bit pattern into a long.
 *
 * @param	x		the float to load
 * @return			a long filled with the IEEE 754 bit pattern of the float
 */
define_function long math_float_to_bits(float x)
{
    return math_raw_be_to_long(RAW_BE(x))
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
    low = low >> 1 + ((hi & 1) << 15)
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
    hi = ((hi & $7FFFFFFF) << 1) + ((low & $80000000) >> 15)
    low = (low & $7FFFFFFF) << 1
	return math_build_double(hi, low)
}

/**
 * Returns TRUE if the argument has no decimal component, otherwise returns
 * FALSE.
 *
 * @todo			look up the exponent of the number as stored in IEEE754
 *					format to all it to function over all values
 * @param	x		the double to check
 * @return			a boolean representing the number's 'wholeness'
 */
define_function char math_is_whole_number(double x)
{
    stack_var slong wholeComponent
    wholeComponent = type_cast(x)
    return wholeComponent == x
}

/**
 * Compares two numbers and return true if they are within MATH_PRECISION of
 * each other.
 *
 * @param	x		a number to compare
 * @param	y		another number to compare to x
 * @return			a boolean specifying if x and y are within MATH_PRECISION of each other
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
 * @return			a signed long containing the rounded number
 */
define_function slong ceil(double x)
{
    if (x > 0 && !math_is_whole_number(x)) {
		return type_cast(x + 1.0)
    } else {
		return type_cast(x)
    }
}

/**
 * Returns the largest (closest to positive infinity) long value that is not
 * greater than the argument and is equal to a mathematical integer.
 *
 * @param	x		a double to round
 * @return			a signed long containing the rounded number
 */
define_function slong floor(double x)
{
    if (x < 0 && !math_is_whole_number(x)) {
		return type_cast(x - 1.0)
    } else {
		return type_cast(x)
    }
}

/**
 * Rounds a flouting point number to it's closest whole number.
 *
 * @param	x		a double to round
 * @return			a signed long containing the rounded number
 */
define_function slong round(double x)
{
    return floor(x + 0.5)
}

/**
 * Calculate the square root of the passed number.
 *
 * This function takes a log base 2 approximation then iterates a Babylonian
 * refinement until the answer is within the math libraries defined precision.
 *
 * @param	x		the double to find the square root of
 * @return			a double containing the square root
 */
define_function double sqrt(double x)
{
	stack_var long hi
	stack_var long low
    stack_var double tmp
	if (x == 0 ||
		x == MATH_NEGATIVE_INFINITY ||
		x == MATH_POSITIVE_INFINITY ||
		x == MATH_NaN) {
		return x
	}
	tmp = math_rshift_double(x)
	hi = (1 << 29) + math_double_high_to_bits(tmp) - (1 << 19)
	low = math_double_low_to_bits(tmp)
	tmp = math_build_double(hi, low)
	while (!math_near(tmp * tmp, x)) {
		tmp = 0.5 * (tmp + (x / tmp))
	}
	return tmp
}

/**
 * Approximate the inverse square root of the passed number.
 *
 * This method uses a integer shift and single Newton refinement aka Quake 3
 * method. Original algorithm by Greg Walsh.
 *
 * @param	x		the float to find the inverse square root of
 * @return			a float containing an approximation of the inverse square root
 */
define_function float fast_inv_sqrt(float x)
{
    stack_var long bits
    stack_var float tmp
    bits = $5F3759DF - (math_float_to_bits(x) >> 1)
    tmp = math_build_float(bits)
    return tmp * (1.5 - 0.5 * x * tmp * tmp)
}

/**
 * Approximate the square root of the passed number based on the inverse square
 * root algorithm in mathInvSqrt(x). This is MUCH faster than sqrt(x) and
 * recommended over sqrt() for use anywhere a precise square root is not
 * required. Error is approx +/-0.15%.
 *
 * @param	x		the float to find the square root of
 * @return			a float containing an approximation of the square root
 */
define_function float fast_sqrt(float x)
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
    while (partial > MATH_PRECISION) {
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

MATH_NaN = math_build_double($FFFFFFFF, $FFFFFFFF)
MATH_POSITIVE_INFINITY = math_build_double($7FF00000, $00000000)
MATH_NEGATIVE_INFINITY = math_build_double($FFF00000, $00000000)

#end_if