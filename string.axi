program_name='string'
#if_not_defined __NCL_LIB_STRING
#define __NCL_LIB_STRING


include 'io'


define_constant
STRING_RETURN_SIZE_LIMIT	= 1024	// Maximum string return size
									// for string manipulation functions.


/**
 * Callback triggered when a funcion within this string processing library
 * attempts to process anything that will result in a return size greater than
 * that defined by STRING_RETURN_SIZE_LIMIT.
 *
 * Anything returned by this will be used as the return of the function that
 * caused the error.
 *
 * @return		An error string.
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_size_error()
{
    // handle, alert, ignore etc here
    println("'Maximum return size too small in String.axi'")

    return 'error'
}

/**
 * Concatenates elements of an array of strings into a single string with a
 * delimiter string inserted between each item.
 *
 * @param	strings		the string array to implode
 * @param	delim		the character string to insert between the imploded
						elements
 * @return				the imploded string
 */
define_function char[STRING_RETURN_SIZE_LIMIT] implode(char strings[][],
		char delim[])
{
    stack_var char ret[STRING_RETURN_SIZE_LIMIT + 1]
	stack_var integer i
    stack_var integer len

    len = length_array(strings)
    ret = strings[1]

    if (len > 1) {
		for (i =len - 1; i; i--) {
			ret = "ret, delim, strings[(len - i) + 1]"
		}
    }

    if (length_string(ret) > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
    }

    return ret
}

/**
 * Explodes a string with a char delimiter into an array of strings.
 * The exploded data will be placed into ret[].
 * Due to NetLinx bugs, you must specify the length of ret in ret_len if you
 * want the returned array sanitized.
 *
 * @todo				Don't make quoted strings necessary; explode based on a
						string instead of a char
 * @param	delim		the delimiter to use for the exploding
 * @param	a			the string array to explode
 * @param	ret			the returned exploded string array of string arrays
 * @param	ret_len		the amount of entries in ret[][]; pass 0 if you don't
						care about sanitizing ret[][]
 * @return				the amount of entries stuffed into ret[][]
 */
define_function integer explode(char delim, char a[], char ret[][], 
		integer ret_len)
{
	return explode_quoted(delim, a, ret, ret_len, 0)
}

/**
 * Explodes a string with a char delimiter into an array of strings.
 * The exploded data will be placed into ret[].
 * Honors quotes; a character passed as quote (such as double quotes) are
 * treated as one segment.
 * Due to NetLinx bugs, you must specify the length of ret in ret_len if you
 * want the returned array sanitized.
 *
 * @todo				Don't make quoted strings necessary; explode based on a
						string instead of a char
 * @param	delim		the delimiter to use for the exploding
 * @param	a			the string array to explode
 * @param	ret			the returned exploded string array of string arrays
 * @param	ret_len		the amount of entries in ret[][]; pass 0 if you don't
						care about sanitizing ret[][]
 * @param	quote		character to use as a quote
 * @return				the amount of entries stuffed into ret[][]
 */
define_function integer explode_quoted(char delim, char a[], char ret[][],
		integer ret_len, char quote)
{
    stack_var integer i
    stack_var integer start
    stack_var integer end

    start = 1
    i = 1

    while (start <= length_string(a)) {
		if (quote) {
			if (a[start] == quote) {				// handle quotes
				end = find_string(a, "quote", start + 1)
				if (end) {
					ret[i] = mid_string(a, start + 1, (end - start) - 1)
					i++

					start = end + 1
					continue
				}
			}
		}

		end = find_string(a, "delim", start)// nothing else stopping us?
		if (end) {								// then seperate by delimiter
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
 * Checks to see if the passed character is a printable ASCII character.
 *
 * @param	a			the character to check
 * @return				a boolean value specifying whether it is printable
 */
define_function char char_is_printable(char a)
{
    return a > $20 && a <= $7E
}

/**
 * Checks to see if the passed character is a whitespace character.
 *
 * @param	a			the character to check
 * @return				a boolean value specifying whether the character is
						whitespace
 */
define_function char char_is_whitespace(char a)
{
    return (a >= $09 && a <= $0D) || (a >= $1C && a <= $20)
}

/**
 * Returns a copy of the string with the left whitespace removed. If no
 * printable characters are found, an empty string will be returned.
 *
 * @param	a			a string to trim
 * @return				the original string with left whitespace removed
 */
define_function char[STRING_RETURN_SIZE_LIMIT] ltrim(char a[])
{
    stack_var char ret[STRING_RETURN_SIZE_LIMIT + 1]
	stack_var integer i
    stack_var integer len

    len = length_string(a)

    for (i = 1; i <= len; i++) {
		if (!char_is_whitespace(a[i])) {
			ret = right_string(a, len - i + 1)
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
define_function char[STRING_RETURN_SIZE_LIMIT] rtrim(char a[])
{
    stack_var integer i
	stack_var integer len

	len = length_string(a)

    for (i = len; i; i--) {
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
define_function char[STRING_RETURN_SIZE_LIMIT] trim(char a[])
{
	return ltrim(rtrim(a))
}

/**
 * Converts a boolean value to its string equivalent of either a 'ON' or 'OFF'.
 *
 * @param	a		a boolean value to convert
 * @return			a string equivalent (as ON/OFF)
 */
define_function char[3] bool_to_string(char a)
{
    if (a) {
		return 'ON'
    } else {
		return 'OFF'
	}
}

/**
 * Converts common string representations of boolean values into their boolean
 * value equivalents.
 *
 * @param	a		a string representing a boolean value
 * @return			a boolean value equivalent
 */
define_function char string_to_bool(char a[])
{
    stack_var char tmp[8]

    tmp = lower_string(trim(a))

    if (tmp == 'on' ||
		tmp == 'true' ||
		tmp == 'yes' ||
		tmp == 'y' ||
		tmp == '1') {

		return TRUE
    } else {
		return FALSE
    }
}

/**
 * Converts an integer array into a comma serperated string list of its values.
 *
 * @param	ints		an intger array of values to 'listify'
 * @param	delim		a string array to insert between entries
 * @return				a string list of the values
 */
define_function char[STRING_RETURN_SIZE_LIMIT] int_array_to_string(
		integer ints[], char delim[])
{
    stack_var char list[STRING_RETURN_SIZE_LIMIT + 1]
	stack_var integer i
    stack_var integer len
    stack_var integer item

    len = length_array(ints)

    list = itoa(ints[1])

    if (len > 1) {
		for (i = len - 1; i; i--) {
			item = (len - i) + 1
			list = "list, delim, itoa(ints[item])"
		}
    }

	if (length_string(list) > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
	}

    return list
}

/**
 * Gets an item from a string list. This can be used to grab word n within
 * a string by passing 'space' as the delimiter.
 *
 * @param	a			a string to split
 * @param	delim		the character string which divides the list entries
 * @param	item		the item number to return
 * @return				a string array the requested list item
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_get_list_item(char a[],
		char delim[], integer item)
{
    stack_var integer ret
    stack_var integer i
    stack_var integer start
    stack_var integer end

    for (i = 1; i <= item; i++) {
		start = end + 1
		end = find_string(a, delim, start)
    }

    if (!end) {
		end = length_string(a) + 1
    }

    ret = end - start

	if (ret > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
    }

	return mid_string(a, start, ret)
}

/**
 * Gets the key from a single key/value pair string with the specified
 * delimiter.
 *
 * @param	a			a string containing a key/value pair
 * @param	delim		the string which divides the key and value
 * @return				a string containing the key component
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_get_key(char a[],
		char delim[])
{
    stack_var integer pos
    stack_var integer retlen

    pos = find_string(a, delim, 1)

    if (pos) {
		retlen = pos - 1
    } else {
		retlen = length_string(a)
    }

    if (retlen > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
    }

	return left_string(a, retlen)
}

/**
 * Gets the value from a key/value pair string with the specified delimiter.
 *
 * @param	a			a string containing a key/value pair
 * @param	delim		the string which divides the key and value
 * @return				a string containing the value component
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_get_value(char a[],
		char delim[])
{
    stack_var integer pos
    stack_var integer retlen

    pos = find_string(a, delim, 1)

    retlen = length_string(a) - (pos + length_string(delim) - 1)

    if (retlen > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
    }

	return right_string(a, retlen)
}

/**
 * Switches the day and month fields of a date string (for coverting between US
 * and international standards). for example 05/28/2009 becomes 28/05/2009.
 *
 * @todo			merge this into a time date lib with unixtime
 * @param	a		a string representation of a date in the form xx/xx/xxxx
 * @return			a string representing the same date with the first two
 *					components reversed
 */
define_function char[10] string_date_invert(char a[])
{
    stack_var integer idx
    stack_var char comp[3][4]

    for (idx = 3; idx; idx--) {
		comp[idx] = string_get_list_item(a, "'/'", idx)
    }

    return "comp[2], '/', comp[1], '/', comp[3]"
}

/**
 * Gets the first instance of a string contained within the bounds of two
 * substrings
 *
 * @param	a		a string to split
 * @param	left	the character sequence marking the left bound
 * @param	right	the character sequence marking the right bound
 * @return			a string contained within the boundary sequences
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_get_between(char a[],
		char left[], char right[])
{
    stack_var integer start
    stack_var integer end
    stack_var integer retlen

    start = find_string(a, left, 1)
	if (start) {
		start = start + length_string(left)
	} else {
		return ''
	}

	end = find_string(a, right, start)
    if (!end) {
		return ''
	}

	retlen = end - start

    if (retlen > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
    }

	return mid_string(a, start, retlen)
}


/**
 * Returns a copy of a string with the first alpha character capitalized.
 * Non alpha characters are not modified. Pass a LOWER_STRING()'d string
 * to lowercase all other characters.
 *
 * @param	a		a string to capitalize first characters of
 * @return			a capitalized string
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_ucfirst(char a[])
{
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
 * lower_string()'d string to lowercase all other characters.
 *
 * @param	a		a string to capitalize first characters of
 * @return			a capitalized string
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_ucwords(char a[])
{
    stack_var char ret[STRING_RETURN_SIZE_LIMIT]
	stack_var integer i

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
 * @param	value	the value to prefix on the string
 * @param	len		the requested length of the string
 * @return			a string prefixed to length len with value
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_prefix_to_length(
		char a[], char value, integer len)
{
    stack_var char ret[STRING_RETURN_SIZE_LIMIT]
	stack_var integer i

	if (len > STRING_RETURN_SIZE_LIMIT ||
		length_string(a) > STRING_RETURN_SIZE_LIMIT) {

		return string_size_error()
	}

    if (length_string(a) < len) {
		for (i = length_string(a); i < len; i++) {
			ret = "value, ret"
		}
    }

    return "ret, a"
}

/**
 * Returns a string suffixed with a specified value, up to a specified length.
 * If the string is the same size or is larger than the specified length,
 * returns the original string.
 *
 * @todo			Possibly allow value to be a string?
 * @param	a		the string to suffix
 * @param	value	the value to suffix on the string
 * @param	len		the requested length of the string
 * @return			a string suffixed to length len with value
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_suffix_to_length(
		char a[], char value, integer len)
{
    stack_var char ret[STRING_RETURN_SIZE_LIMIT]
	stack_var integer i

    if (len > STRING_RETURN_SIZE_LIMIT ||
		length_string(a) > STRING_RETURN_SIZE_LIMIT) {

		return string_size_error()
	}

	if (length_string(a) < len) {
		for (i = length_string(a); i < len; i++) {
			ret = "value, ret"
		}
    }

    return "a, ret"
}

/**
 * Returns the left substring of a string up to the specified number of
 * characters.
 * WARNING: this is a destructive removal - the returned substring will be
 * removed from string 'a'.
 *
 * @param	a		a string to remove the substring from
 * @param	len		the number of characters to remove
 * @return			a string containing the first 'len' characters of 'a'
 */
define_function char[STRING_RETURN_SIZE_LIMIT] remove_string_by_length(
		char a[], integer len)
{
	if (len > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
	}

	return remove_string(a, left_string(a, len), 1)
}


/**
 * Returns a url-encoded string according to RFC 1736 / RFC 2732.
 *
 * @todo			finish this function - it is very incomplete
 * @param	a		the string to urlencode
 * @return			a string urlencoded
 */
define_function char[STRING_RETURN_SIZE_LIMIT] urlencode(char a[])
{
	stack_var char ret[STRING_RETURN_SIZE_LIMIT + 1]
	stack_var integer i

	for (i = 1; i <= length_string(a); i++) {
		if ((a[i] >= $30 && a[i] <= $39) ||			// numerics
			(a[i] >= $41 && a[i] <= $5a) ||			// uppercase
			(a[i] >= $61 && a[i] <= $7a) ||			// lowercase
			a[i] == '$' || a[i] == '-' || a[i] == '_' ||
			a[i] == '.' || a[i] == '+' || a[i] == '!' ||
			a[i] == '*' || a[i] == $27 || a[i] == '(' ||
			a[i] == ')' || a[i] == ',' || a[i] == '[' || a[i] == ']') {

			ret = "ret, a[i]"
		} else {
			ret = "ret, '%', string_prefix_to_length(itohex(a[i]), '0', 2)"
		}
	}


	if (length_string(ret) > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
	}

	return ret
}

/**
 * Search through a string for a match against a list of possible substrings
 * and return the element index of the matched string
 *
 * @param	haystack	a string to search
 * @param	needle		a list of substrings to match
 * @param	start		the array element to begin searching from
 * @return				an integer containing the the element index of needles
 *						that was matched (0 if not found)
 */
define_function integer find_string_multi(char haystack[], char needles[][],
		integer start)
{
    stack_var integer i
	stack_var integer len

	len = length_array(needles)

	for (i = start; i <= len; i++) {
		if (find_string(haystack, needles[i], 1)) {
			return i
		}
	}

	return 0
}

/**
 * Replace all occurances of a substring with another string.
 *
 * @param	a			the string to search
 * @param	search		the substring to replace
 * @param	replace		the replacement subtring
 * @return				'a' with all occurances of 'search' replaced by the
 *						contents of 'replace'
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_replace(char a[], 
		char search[], char replace[])
{
	stack_var integer start
	stack_var integer end
	stack_var char ret[STRING_RETURN_SIZE_LIMIT]

	if (length_string(a) > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
    }

	start = 1
	end = find_string(a, search, start)

	while (end) {
		ret = "ret, mid_string(a, start, end - start), replace"
		start = end + length_string(search)
		end = find_string(a, search, start)
	}

	ret = "ret, right_string(a, length_string(a) - start + 1)"

	return ret
}

/**
 * Reverse a string.
 *
 * @param	a			the string to reverse
 * @return				the contents of 'a' with the character order reversed
 */
define_function char[STRING_RETURN_SIZE_LIMIT] string_reverse(char a[])
{
	stack_var integer i
	stack_var integer len
	stack_var char ret[STRING_RETURN_SIZE_LIMIT]

	len = length_string(a)

	if (len > STRING_RETURN_SIZE_LIMIT) {
		return string_size_error()
    }

	for (i = len; i; i--) {
		ret[(len - i) + 1] = a[i];
	}

	set_length_string(ret, len);

	return ret
}


/**
 * Remove characters from the end of the string.
 * 
 * @param	a			the input string
 * @param	count		the number of characters to remove
 * @return				the contents of 'a' with the characters removed
 */
define_function char[STRING_RETURN_SIZE_LIMIT] strip_chars_right(char a[], 
		integer count)
{
	return left_string(a, length_string(a) - count)
}

/**
 * Wrapper method for mid_string to bring inline with other programming
 * languages.
 * 
 * @param	a			the input string
 * @param	start		the start location of the substring
 * @param	count		the number of characters to extract
 */
define_function char[STRING_RETURN_SIZE_LIMIT] substr(char a[], integer start, 
		integer count)
{
	return mid_string(a, start, count);
}

/**
 * Alternative to substr which allows an end location to be specified instead of
 * a count
 *
 * @param	a			the input string
 * @param	start		the start location of the substring
 * @param	end			the end location of the substring
 */
define_function char[STRING_RETURN_SIZE_LIMIT] substring(char a[], 
		integer start, integer end)
{
	return substr(a, start, end-start+1);
}

define_function CHAR[STRING_RETURN_SIZE_LIMIT] pad_leading_chars(char a[], char pad, 
		integer count)
{
	stack_var char ret[STRING_RETURN_SIZE_LIMIT]
	
	ret = a;
	if (count == 0) {
		return ''						// Emergency Exit
	}
	while(length_string(ret) <  count){ 
		ret = "pad, ret" 
	}
	
	return ret;
}

#end_if