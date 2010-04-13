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
 *
 */
PROGRAM_NAME='String'


DEFINE_VARIABLE

constant STRING_RETURN_SIZE_LIMIT = 1024	// Maximum string return size
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
define_function char[STRING_RETURN_SIZE_LIMIT] string_size_error () {
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
define_function char[STRING_RETURN_SIZE_LIMIT] string_implode (char strings[][], char delimiter[]) {
    stack_var integer index
    stack_var integer arraySize
    stack_var char implodedString[STRING_RETURN_SIZE_LIMIT + 1]

    arraySize = length_array(strings)
    implodedString = strings[1]

    if (arraySize > 1) {
	for (index = arraySize - 1; index; index--) {
	    implodedString = "implodedString, delimiter, strings[(arraySize - index) + 1]"
	}
    }

    if (length_string(implodedString) > STRING_RETURN_SIZE_LIMIT) {
	return string_size_error()
    }

    return implodedString
}

/**
 * Checks to see if the passed character is a printable ascii character.
 *
 * @param	charToTest	the character to check
 * @return			a boolean value specifying whether it is printable
 */
define_function char string_is_printable (char charToTest) {
    return charToTest > $20 && charToTest < $7F
}

/**
 * Checks to see if the passed character is a whitespace character.
 *
 * @param	charToTest	the character to check
 * @return			a boolean value specifying whether it is a whitepsace character
 */
define_function char string_is_whitespace (char charToTest) {
    return (charToTest > $08 && charToTest < $0E) ||
	(charToTest > $1B && charToTest < $20)
}

/**
 * returns a copy of the string with the left whitespace removed. if no
 * printable characters are found an empty string will be returned.
 *
 * @param	a		a string to trim
 * @return			the original string with left whitespace removed
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_ltrim (char a[]) {
    stack_var integer index
    stack_var integer length
    stack_var char trimmed[STRING_RETURN_SIZE_LIMIT + 1]

    length = length_string(a)

    for (index = length; index; index--) {
	if (!string_is_whitespace(a[(length + 1) - index])) {
	    trimmed = right_string(a, (length + 1) - index)
	    if (length_string(trimmed) > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
	    } else {
		return trimmed
	    }
	}
    }
}

/**
 * returns a copy of the string with the right whitespace removed. if no
 * printable characters are found an empty string will be returned.
 *
 * @param	a		the string to trim
 * @return			the string with right whitespace removed
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_rtrim (char a[]) {
    stack_var integer index

    for (index = length_string(a); index; index--) {
	if (!string_is_whitespace(a[index])) {
	    if (index > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
	    } else {
		return left_string(a, index)
	    }
	}
    }
}

/**
 * returns a copy of the string with the whitespace removed. if no  printable
 * characters are found an empty string will be returned.
 *
 * @param	a		a string to trim
 * @return			the original string with whitespace removed
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_trim (char a[]) {
    stack_var integer index
    stack_var integer length
    stack_var integer startIndex
    stack_var integer endIndex
    stack_var integer returnLength

    length = length_string(a)
						// We could just ltrim() and rtrim() however
    for (index = length; index; index--) {	// this should speed things up as the loop
	if (!startIndex) {			// only needs to execute once.
	    if (!string_is_whitespace(a[(length + 1) - index])) {
		startIndex = (length + 1) - index
	    }
	}
	if (!endIndex) {
	    if (!string_is_whitespace(a[index])) {
		endIndex = index + 1
	    }
	}
	if (startIndex && endIndex) {
	    returnLength = endIndex - startIndex
	    if (returnLength > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
	    } else {
		return mid_string(a, startIndex, returnLength)
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
define_function char[3] string_from_boolean (char boolean) {
    switch (boolean) {
	case TRUE: return 'ON'
	case FALSE: return 'OFF'
    }
}

/**
 * Converts common string representations of boolean values into their boolean
 * value equivalents.
 *
 * @param	a		a string representing a boolean value
 * @return			a boolean value equivalent
 */
define_function char string_to_boolean (char a[]) {
    stack_var char temp[32]
    temp = lower_string(string_trim(a))
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
define_function char[STRING_RETURN_SIZE_LIMIT] string_from_int_array (integer ints[]) {
    stack_var integer index
    stack_var integer arraySize
    stack_var integer returnLength
    stack_var integer item
    stack_var char list[STRING_RETURN_SIZE_LIMIT]

    arraySize = length_array(ints)

    list = itoa(ints[1])

    if (arraySize > 1) {
	for (index = arraySize - 1; index; index--) {
	    item = (arraySize - index) + 1

	    returnLength = returnLength + length_string(itoa(ints[item]))
	    if (returnLength > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
	    }

	    list = "list, ',', itoa(ints[item])"
	}
    }

    return list
}

/**
 * Gets an item from a string list. This can also be used to grab word n within
 * a string by passing 'space' as the delimiter.
 *
 * @param	a		a string to split
 * @param	delimiter	the character string which divides the list entries
 * @param	item		the item number to return
 * @return			a string array the requested list item
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_get_list_item (char a[], char delimiter[], integer item) {
    stack_var integer currentItem
    stack_var integer startIndex
    stack_var integer endIndex
    stack_var integer returnLength

    for (currentItem = 1; currentItem <= item; currentItem++) {
	startIndex = endIndex + 1
	endIndex = find_string(a, delimiter, startIndex)
    }

    if (!endIndex) {
	endIndex = length_string(a) + 1
    }

    returnLength = endIndex - startIndex
    if (returnLength > STRING_RETURN_SIZE_LIMIT) {
	return string_size_error()
    } else {
	return mid_string(a, startIndex, returnLength)
    }
}

/**
 * Gets the key from a key/value pair string with the specified delimiter.
 *
 * @param	a		a string containing a key/value pair
 * @param	delimiter	the character string which divides the key and value
 * @return			a string containing the key component
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_get_key (char a[], char delimiter[]) {
    stack_var integer delimiterPos
    stack_var integer returnLength

    delimiterPos = find_string(a, delimiter, 1)

    if (delimiterPos) {
	returnLength = delimiterPos - 1
    } else {
	returnLength = length_string(a)
    }

    if (returnLength > STRING_RETURN_SIZE_LIMIT) {
	return string_size_error()
    } else {
	return left_string(a, returnLength)
    }
}

/**
 * Gets the value from a key/value pair string with the specified delimiter.
 *
 * @param	a		a string containing a key/value pair
 * @param	delimiter	the character string which divides the key and value
 * @return			a string containing the value component
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_get_value (char a[], char delimiter[]) {
    stack_var integer delimiterPos
    stack_var integer returnLength

    delimiterPos = find_string(a, delimiter, 1)

    returnLength = length_string(a) - (delimiterPos + length_string(delimiter) - 1)

    if (returnLength > STRING_RETURN_SIZE_LIMIT) {
	return string_size_error()
    } else {
	return right_string(a, returnLength)
    }
}

/**
 * Switch the day and month fields of a date string (for coverting between US
 * and international standards). for example 05/28/2009 becomes 28/05/2009.
 *
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
 * Gets the first instance of a string contained within the bounds of the two
 * passed sub strings
 *
 * @param	a		a string to split
 * @param	start		the character sequence marking the left bound
 * @param	end		the character sequence marking the right bound
 * @return			a string contained within the boundary sequences
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_get_contained_string (char a[], char start[], char end[]) {
    stack_var integer startIndex
    stack_var integer endIndex
    stack_var integer returnLength

    startIndex = find_string(a, start, 1) + length_string(start)
    endIndex = find_string(a, end, startIndex)
    returnLength = endIndex - startIndex

    if (returnLength > STRING_RETURN_SIZE_LIMIT) {
	return string_size_error()
    } else {
	return mid_string(a, startIndex, returnLength)
    }
}


/**
 * returns a copy of a string with the first alpha character capitalized and
 * all other characters converted to lower case. Non alpha characters are not
 * modified.
 *
 * @param	a		a string to capitalize
 * @return			a capitalized string
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_capitalize (char a[]) {
    stack_var integer index
    stack_var integer stringLength
    stack_var integer charIndex
    stack_var char temp[STRING_RETURN_SIZE_LIMIT]

    stringLength = length_string(a)

    if (stringLength > STRING_RETURN_SIZE_LIMIT) {
	return string_size_error()
    } else {
	for (index = stringLength; index; index--) {
	    charIndex = (stringLength - index) + 1
	    if ((a[charIndex] >= $41 && a[charIndex] <= $5A) ||	// A - Z
		(a[charIndex] >= $61 && a[charIndex] <= $7A)) {	// a - z
		break
	    }
	}

	temp = lower_string(a)

	temp[charIndex] = temp[charIndex] - $20

	return temp
    }
}
