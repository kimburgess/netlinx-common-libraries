program_name='array'
#if_not_defined __NCL_LIB_ARRAY
#define __NCL_LIB_ARRAY


include 'math'


/**
 * Finds the index for an matching entry in an array.
 *
 * @param	item		item to find in the array
 * @param	list		array of items
 *
 * @return				the index of the matching value, or 0 if no match
 */
define_function integer array_index(dev item, dev list[])
{
    stack_var integer i

    for (i = 1; i <= max_length_array(list); i++) {
		if (item == list[i]) {
			return i
		}
    }

    return 0
}

/**
 * Stub for future qsort function.
 */
define_function qsort()
{

}

/**
 * Finds the minimum value in an integer array
 *
 * @param	list		array of integers
 *
 * @return				the minimum value in the array
 */
define_function integer min(integer list[])
{
	stack_var integer i
	stack_var integer val

	val = 65535;
    for (i = 1; i <= max_length_array(list); i++) {
		val = min_value(val, list[i]);
	}

	return val;
}

/**
 * Finds the maximum value in an integer array
 *
 * @param	list		array of integers
 *
 * @return				the maximum value in the array
 */
define_function integer max(integer list[])
{
	stack_var integer i
	stack_var integer val

	val = 0;
    for (i = 1; i <= max_length_array(list); i++) {
		val = max_value(val, list[i]);
	}

	return val;
}

/**
 * Finds the minimum value in a double array
 *
 * @param	list		array of doubles
 *
 * @return				the minimum value in the array
 */
define_function double mind(double list[])
{
	stack_var integer i
	stack_var double val

	val = MATH_POSITIVE_INFINITY;
    for (i = 1; i <= max_length_array(list); i++) {
		if (list[i] < val) {
			val = list[i];
		}
	}

	return val;
}

/**
 * Finds the maximum value in a double array
 *
 * @param	list		array of doubles
 *
 * @return				the maximum value in the array
 */
define_function double maxd(double list[])
{
	stack_var integer i
	stack_var double val

	val = MATH_NEGATIVE_INFINITY;
    for (i = 1; i <= max_length_array(list); i++) {
		if (list[i] > val) {
			val = list[i];
		}
	}

	return val;
}


#end_if