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

/**
 * In-place sorting of an integer array using a non-recursive quicksort method.
 *
 * @param	list		array of integers
 *
 * @return				nothing
 */ 
define_function quicksort(integer list[])
{
	stack_var integer stack_count  // current stack size
	stack_var integer stack[16][2] // stack size with log2(N) slots required: N = max allowable number
	stack_var integer pivot        // current pivot value
	stack_var integer lo, hi       // current lower and upper indices

	stack_count = 1
	stack[stack_count][1] = 1
	stack[stack_count][2] = length_array(list)

	while (stack_count) {
		lo = stack[stack_count][1]
		hi = stack[stack_count][2]
		if (lo < hi) {
			pivot = list[lo]
			while (lo < hi) {
				while (list[hi] >= pivot && lo < hi) {
					hi--
				}
				if (lo < hi) {
					list[lo] = list[hi]
					lo++
				}
				while (list[lo] <= pivot && lo < hi) {
					lo++
				}
				if (lo < hi) {
					list[hi] = list[lo]
					hi--
				}
			}
			list[lo] = pivot
			stack_count++
			stack[stack_count][1] = lo + 1
			stack[stack_count][2] = stack[stack_count - 1][2]
			stack[stack_count - 1][2] = lo
		}
		else {
			stack_count--
		}
	}
}

/**
 * In-place sorting of an integer array using the insertion sort method.
 * Efficient for small data sets.
 * Crude testing on a NI-900 suggests that insertion sort is faster than the
 * non-recursive quicksort for random integer arrays up to a size of about 25
 * elements.
 *
 * @param	list		array of integers
 *
 * @return				nothing
 */
define_function insertionsort(integer list[])
{
	stack_var integer length
	stack_var integer n
	stack_var integer val
	stack_var integer hole_pos

	length = length_array(list)
	for (n = 2; n <= length; n++) {
		val = list[n]
		hole_pos = n
		while (val < list[hole_pos - 1]) {
			list[hole_pos] = list[hole_pos - 1]
			hole_pos--
			if (hole_pos == 1) {
				break
			}
		}
		list[hole_pos] = val
	}
}

/**
 * In-place partitioning of an integer array.  It partitions the portion of the
 * array between indices left and right inclusive by moving all elements less
 * than list[pivot_index] before the pivot and those equal or greater after it.
 *
 * @param	list		array of integers
 * @param	left		index of first element of the sub-array to partition
 * @param	right		index of second element of the sub-array to partition
 * @param	pivot_index	index of the pivot element
 *
 * @return				nothing
 */
define_function integer partition(integer list[], integer left, integer right, integer pivot_index)
{
	stack_var integer pivot_value
	stack_var integer store_index
	stack_var integer n

	store_index = 0
	if (left <= pivot_index && pivot_index <= right && left && right <= length_array(list)) {
		pivot_value = list[pivot_index]
		swap(list, pivot_index, right)
		store_index = left
		for (n = left; n < right; n++) {
			if (list[n] <= pivot_value) {
				swap(list, n, store_index)
				store_index++
			}
		}
		swap(list, store_index, right)
	}
	return store_index
}

/**
 * In-place swap of two elements in an integer array
 *
 * @param	list		array of integers
 * @param	index1		index of the first element to swap
 * @param	index2		index of the second element to swap
 *
 * @return				nothing
 */
define_function swap(integer list[], integer index1, integer index2)
{
	stack_var integer length
	stack_var integer temp_store

	length = length_array(list)
	if (index1 && index1 <= length && index2 && index2 <= length) {
		temp_store = list[index1];
		list[index1] = list[index2]
		list[index2] = temp_store
	}
}

#end_if