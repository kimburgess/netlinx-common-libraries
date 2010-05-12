/**
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code provides a collection of useful functions to assist in
 * array manipulation and parsing within the NetLinx language.
 *
 * Portions created by the Initial Developer are Copyright (C) 2010 the
 * Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *	true <amx at trueserve dot org>
 * 	Kim Burgess <kim.burgess@justice.qld.gov.au>
 *
 *
 * $Id$
 * tab-width: 4 columns: 80
 */

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