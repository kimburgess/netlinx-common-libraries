program_name='array'
#if_not_defined __NCL_LIB_ARRAY
#define __NCL_LIB_ARRAY

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

#end_if