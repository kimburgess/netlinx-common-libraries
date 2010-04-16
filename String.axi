PROGRAM_NAME='String'

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
 * string manipulation and parsing within the NetLinx language.
 *
 * The Initial Developer of the Original Code is Queensland Department of
 * Justice and Attorney-General.
 * Portions created by the Initial Developer are Copyright (C) 2010 the
 * Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 * 	Kim Burgess <kim.burgess@justice.qld.gov.au>
 *	true <amx at trueserve dot org>
 *
 * $Id$
 * tab-width: 8, indent: 4, columns: 80
 */

#if_not_defined __STRING_LIB
#define __STRING_LIB


define_constant
STRING_RETURN_SIZE_LIMIT	= 1024	// Maximum string return size
					// for string manipulation
					// functions.


/**
 * Callback triggered when a funcion within this string processing library
 * attempt so process anything that will result in a return size greater than
 * that defined by STRING_RETURN_SIZE_LIMIT.
 *
 * Anything returned by this will be used as the return of the function that
 * caused the error.
 *
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_size_error() {
    // handle, alert, ignore etc here
    send_string 0 , "'Return size to small in String.axi'"

    return 'error'
}

/**
 * Concatenates elements of an array of strings into a single string with a
 * delimiter string inserted between each item.
 *
 * @param	strings		the string array to implode
 * @param	deliminator	the character string to insert between the imploded elements
 * @return			the imploded string
 */
define_function char[STRING_RETURN_SIZE_LIMIT] implode(char strings[][], char delimiter[]) {
    stack_var integer	i
    stack_var integer	size
    stack_var char	ret[STRING_RETURN_SIZE_LIMIT + 1]

    size = length_array(strings)
    ret = strings[1]

    if (size > 1) {
	for (i = size - 1; i; i--) {
	    ret = "ret, delimiter, strings[(size - i) + 1]"
	}
    }

    if (length_string(ret) > STRING_RETURN_SIZE_LIMIT) {
	return string_size_error()
    }

    return ret
}

/**
 * Explodes a string with a char delimiter into an array of string arrays.
 * Honors quotes; double quoted contents are treated as one segment.
 * Due to NetLinx bugs, you must specify the length of ret in ret_len if you
 * want the returned array sanitized.
 *
 * @todo			Don't make quoted strings necessary; explode based on a string instead of a char
 * @param	delim		the delimiter to use for the exploding
 * @param	a		the string array to explode
 * @param	ret		the returned exploded string array of string arrays
 * @param	ret_len		the amount of entries in ret[][]; pass 0 if you don't care about sanitizing ret[][]
 * @return			the amount of entries stuffed into ret[][]
 */
define_function integer explode(char delim, char a[], char ret[][], integer ret_len)
{
    stack_var integer	i
    stack_var integer	start
    stack_var integer	end

    start = 1
    i = 1

    while (start <= length_string(a)) {
	if (a[start] == delim) {			// skip delimiter
	    start++
	    continue
	}

	if (a[start] == '"') {				// handle quotes
	    end = find_string(a, '"', start + 1)

	    ret[i] = mid_string(a, start + 1, (end - start) - 1)
	    i++

	    start = end + 1
	    continue
	}

	end = find_string(a, "delim", start)		// nothing else stopping us?
							// then seperate by delimiter
	if (end) {
	    ret[i] = mid_string(a, start, (end - start))
	    i++

	    start = end + 1
	} else {
	    ret[i] = mid_string(a, start, length_string(a))

	    start = length_string(a) + 1
	}
    }

    for (start = i + 1; start <= ret_len; start++) {
	ret[start] = ''
    }

    return i
}

/**
 * Checks to see if the passed character is a printable ascii character.
 *
 * @param	test		the character to check
 * @return			a boolean value specifying whether it is printable
 */
define_function char char_is_printable(char test) {
    return test > $20 && test < $7F
}

/**
 * Checks to see if the passed character is a whitespace character.
 *
 * @param	test		the character to check
 * @return			a boolean value specifying whether it is a whitepsace character
 */
define_function char char_is_whitespace(char test) {
    return (test > $08 && test < $0E) ||
	(test > $1B && test < $21)
}

/**
 * Returns a copy of the string with the left whitespace removed. If no
 * printable characters are found, an empty string will be returned.
 *
 * @param	a		a string to trim
 * @return			the original string with left whitespace removed
 */
define_function char[STRING_RETURN_SIZE_LIMIT] ltrim(char a[]) {
    stack_var integer	i
    stack_var integer	len
    stack_var char	ret[STRING_RETURN_SIZE_LIMIT + 1]

    len = length_string(a)

    for (i = len; i; i--) {
	if (!char_is_whitespace(a[(len + 1) - i])) {
	    ret = right_string(a, (len + 1) - i)
	    if (length_string(ret) > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
	    } else {
		return ret
	    }
	}
    }
}

/**
 * Returns a copy of the string with the right whitespace removed. If no
 * printable characters are found, an empty string will be returned.
 *
 * @param	a		the string to trim
 * @return			the string with right whitespace removed
 */
define_function char[STRING_RETURN_SIZE_LIMIT] rtrim(char a[]) {
    stack_var integer	i

    for (i = length_string(a); i; i--) {
	if (!char_is_whitespace(a[i])) {
	    if (i > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
	    } else {
		return left_string(a, i)
	    }
	}
    }
}

/**
 * Returns a copy of the string with the whitespace removed. If no printable
 * characters are found, an empty string will be returned.
 *
 * @param	a		a string to trim
 * @return			the original string with whitespace removed
 */
define_function char[STRING_RETURN_SIZE_LIMIT] trim(char a[]) {
    stack_var integer	i
    stack_var integer	len
    stack_var integer	start
    stack_var integer	end
    stack_var integer	returnlen

    len = length_string(a)
					// We could just ltrim() and rtrim(),
    for (i = len; i; i--) {		// however this should be faster as the
	if (!start) {			// loop only needs to execute once.
	    if (!char_is_whitespace(a[(len + 1) - i])) {
		start = (len + 1) - i
	    }
	}
	if (!end) {
	    if (!char_is_whitespace(a[i])) {
		end = i + 1
	    }
	}
	if (start && end) {
	    returnlen = end - start
	    if (returnlen > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
	    } else {
		return mid_string(a, start, returnlen)
	    }
	}
    }
}

/**
 * Converts a boolean value to its string equivalent of either a 'ON' or 'OFF'.
 *
 * @param	boolean		a boolean value to convert
 * @return			a string equivalent
 */
define_function char[3] boolean_to_string(char boolean) {
    if (boolean) {
	return 'ON'
    }
    return 'OFF'
}

/**
 * Converts common string representations of boolean values into their boolean
 * value equivalents.
 *
 * @param	a		a string representing a boolean value
 * @return			a boolean value equivalent
 */
define_function char string_to_boolean(char a[]) {
    stack_var char	temp[32]

    temp = lower_string(trim(a))
    if (temp == 'on' ||
	temp == 'true' ||
	temp == 'yes' ||
	temp == 'y' ||
	temp == '1') {

	return TRUE
    } else {
	return FALSE
    }
}

/**
 * Converts an integer array into a comma serperated string list of its values.
 *
 * @param	ints		am intger array of values to 'listify'
 * @return			a string list of the values
 */
define_function char[STRING_RETURN_SIZE_LIMIT] int_array_to_string(integer ints[]) {
    stack_var integer	i
    stack_var integer	size
    stack_var integer	returnlen
    stack_var integer	item
    stack_var char	list[STRING_RETURN_SIZE_LIMIT]

    size = length_array(ints)

    list = itoa(ints[1])

    if (size > 1) {
	for (i = size - 1; i; i--) {
	    item = (size - i) + 1

	    returnlen = returnlen + length_string(itoa(ints[item]))
	    if (returnlen > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
	    }

	    list = "list, ',', itoa(ints[item])"
	}
    }

    return list
}

/**
 * Gets an item from a string list. This can be used to grab word n within
 * a string by passing 'space' as the delimiter.
 *
 * @param	a		a string to split
 * @param	delimiter	the character string which divides the list entries
 * @param	item		the item number to return
 * @return			a string array the requested list item
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_get_list_item(char a[], char delimiter[], integer item) {
    stack_var integer	i
    stack_var integer	start
    stack_var integer	end
    stack_var integer	ret

    for (i = 1; i <= item; i++) {
	start = end + 1
	end = find_string(a, delimiter, start)
    }

    if (!end) {
	end = length_string(a) + 1
    }

    ret = end - start
    if (ret > STRING_RETURN_SIZE_LIMIT) {
	return string_size_error()
    } else {
	return mid_string(a, start, ret)
    }
}

/**
 * Gets the key from a single key/value pair string with the specified
 * delimiter.
 *
 * @param	a		a string containing a key/value pair
 * @param	delimiter	the character string which divides the key and value
 * @return			a string containing the key component
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_get_key(char a[], char delimiter[]) {
    stack_var integer	pos
    stack_var integer	returnlen

    pos = find_string(a, delimiter, 1)

    if (pos) {
	returnlen = pos - 1
    } else {
	returnlen = length_string(a)
    }

    if (returnlen > STRING_RETURN_SIZE_LIMIT) {
	return string_size_error()
    } else {
	return left_string(a, returnlen)
    }
}

/**
 * Gets the value from a key/value pair string with the specified delimiter.
 *
 * @param	a		a string containing a key/value pair
 * @param	delimiter	the character string which divides the key and value
 * @return			a string containing the value component
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_get_value(char a[], char delimiter[]) {
    stack_var integer	pos
    stack_var integer	returnlen

    pos = find_string(a, delimiter, 1)

    returnlen = length_string(a) - (pos + length_string(delimiter) - 1)

    if (returnlen > STRING_RETURN_SIZE_LIMIT) {
	return string_size_error()
    } else {
	return right_string(a, returnlen)
    }
}

/**
 * Switches the day and month fields of a date string (for coverting between US
 * and international standards). for example 05/28/2009 becomes 28/05/2009.
 *
 * QUESTION: Should we have a date/time library? Should this be merged with unixtime?
 */
define_function char[10] string_date_invert(char dateString[]) {
    stack_var integer index
    stack_var char components[3][4]

    for (index = 3; index; index--) {
	components[index] = string_get_list_item(dateString, "'/'", index)
    }

    return "components[2], '/', components[1], '/', components[3]"
}

/**
 * Gets the first instance of a string contained within the bounds of two
 * substrings
 *
 * @param	a		a string to split
 * @param	left		the character sequence marking the left bound
 * @param	right		the character sequence marking the right bound
 * @return			a string contained within the boundary sequences
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_get_between(char a[], char left[], char right[]) {
    stack_var integer	start
    stack_var integer	end
    stack_var integer	returnlen

    start = find_string(a, left, 1) + length_string(left)
    end = find_string(a, right, start)
    returnlen = end - start

    if (returnlen > STRING_RETURN_SIZE_LIMIT) {
	return string_size_error()
    } else {
	return mid_string(a, start, returnlen)
    }
}


/**
 * Returns a copy of a string with the first alpha character capitalized.
 * Non alpha characters are not modified. Pass a LOWER_STRING()'d string
 * to lowercase all other characters.
 *
 * @param	a		a string to capitalize first characters of
 * @return			a capitalized string
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_ucfirst(char a[]) {
    if (length_string(a) > STRING_RETURN_SIZE_LIMIT) {
	return string_size_error()
    }

    if (a[1] >= $61 && a[1] <= $7A) {
	return "a[1] - $20, mid_string(a, 2, STRING_RETURN_SIZE_LIMIT)"
    }
    return a
}

/**
 * Returns a copy of a string with the first alpha character in each word
 * capitalized. Non alpha characters are not modified. Pass a
 * LOWER_STRING()'d string to lowercase all other characters.
 *
 * @param	a		a string to capitalize first characters of
 * @return			a capitalized string
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_ucwords(char a[]) {
    stack_var integer	i
    stack_var char	ret[STRING_RETURN_SIZE_LIMIT]

    if (length_string(a) > STRING_RETURN_SIZE_LIMIT) {
	return string_size_error()
    }

    ret = a

    for (i = 1; i < length_string(ret); i++) {
	if (char_is_whitespace(ret[i])) {
	    if (ret[i + 1] >= $61 && ret[i + 1] <= $7a) {
		ret[i + 1] = ret[i + 1] - $20
	    }
	}
    }

    return ret
}

/**
 * Returns a string prefixed with a specified value, up to a specified length.
 * If the string is the same size or is larger than the specified length,
 * returns the original string.
 *
 * @todo			Possibly allow value to be a string?
 * @param	a		the string to prefix
 * @param	value		the value to prefix on the string
 * @param	len		the requested length of the string
 * @return			a string prefixed to length len with value
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_prefix_to_length(char a[], char value, integer len)
{
    stack_var integer	i
    stack_var char	work[STRING_RETURN_SIZE_LIMIT]

    if (length_string(a) < len) {
	for (i = length_string(a); i < len; i++) {
	    work = "value, work"
	}
    }

    return "work, a"
}

/**
 * Returns a string suffixed with a specified value, up to a specified length.
 * If the string is the same size or is larger than the specified length,
 * returns the original string.
 *
 * @todo			Possibly allow value to be a string?
 * @param	a		the string to suffix
 * @param	value		the value to suffix on the string
 * @param	len		the requested length of the string
 * @return			a string suffixed to length len with value
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_suffix_to_length(char a[], char value, integer len)
{
    stack_var integer	i
    stack_var char	work[STRING_RETURN_SIZE_LIMIT]

    if (length_string(a) < len) {
	for (i = length_string(a); i < len; i++) {
	    work = "value, work"
	}
    }

    return "a, work"
}