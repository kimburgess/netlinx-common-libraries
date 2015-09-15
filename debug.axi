program_name='debug'
#if_not_defined __NCL_LIB_DEBUG
#define __NCL_LIB_DEBUG


include 'io'


define_constant
char DEBUG_OFF		= 0				// Available debug verbosity levels
char DEBUG_ERROR 	= 1
char DEBUG_WARN 	= 2
char DEBUG_INFO 	= 3
char DEBUG_DEBUG    = 4

char DEBUG_MAX_LEVEL = 4

char DEBUG_LEVEL_STRINGS[5][16] = {
    'Off',
    'Error',
    'Warn',
    'Info',
    'Debug'
}


define_variable
persistent char debug_level			// Current system debug level


/**
 * Returns a string representing the debug level passed.
 *
 * @param	x		an char specifying the debug level
 * @return			a string representing the level
 */
define_function char[5] debug_get_level_string(char x)
{
    return DEBUG_LEVEL_STRINGS[x + 1]
}

/**
 * Sets the current system debugging level for controlling debug message
 * verbosity.
 *
 * @param	x		a char specifying the debug level to set
 */
define_function debug_set_level(char x)
{
	if (x >= DEBUG_OFF && x <= DEBUG_MAX_LEVEL) {
		println("'Debug level set to ', debug_get_level_string(x)")
		debug_level = x
	} else {
		debug_msg(DEBUG_WARN, "'Invalid debug level, defaulting to ',
				debug_get_level_string(DEBUG_ERROR)")
		debug_set_level(DEBUG_ERROR)
	}
}

/**
 * Voices a debug message if required by the current debug level. All system
 * messages should pass through here.
 *
 * If the ability to dump to a file or netorked logging service is required it
 * can be added here.
 *
 * @param	msg_level	a char specifying the debug level of the message
 * @param	msg			a string containing the debug message
 */
define_function debug_msg(char msg_level, char msg[])
{
	stack_var long i,l;
	stack_var char c;
	stack_var char out[255];
	stack_var char in[255];

	if (msg_level < DEBUG_ERROR || msg_level > DEBUG_MAX_LEVEL) {
		debug_msg(DEBUG_ERROR, "'invalid debug level specified - ', msg")
		return
	}
	if (msg_level <= debug_level) {
		if (FIND_STRING(msg, "$00", 1) > 0){
			in = msg
			out = ""
			l = LENGTH_STRING(in)
			for (i = 0; i < l; i++){
				c = GET_BUFFER_CHAR(in)
				if(c == "$00"){
					out = "out,'$00'"
				}else{
					out = "out,c"
				}
			}
			println("upper_string(debug_get_level_string(msg_level)),': ', out")
		}else{
			println("upper_string(debug_get_level_string(msg_level)),': ', msg")
		}
	}
}

/**
 * Prints a debug message forced to hex - this avoids situations where a hex 
 * value is a valid ascii character
 *
 * @param	msg_level	a char specifying the debug level of the message
 * @param	msg			a string containing the debug message to be printed as hex
 */
define_function debug_hex(char msg_level, char msg[])
{
	stack_var long i,l;
	stack_var char c;
	stack_var char out[255];
	stack_var char in[255];
	
	if (msg_level < DEBUG_ERROR || msg_level > DEBUG_MAX_LEVEL) {
		debug_msg(DEBUG_ERROR, "'invalid debug level specified - ', msg")
		return
	}
	if (msg_level <= debug_level) {
		in = msg
		out = ""
		l = LENGTH_STRING(in)
		for (i = 0; i < l; i++){
			c = GET_BUFFER_CHAR(in)
			out = "out, '$', itohex(c),','"
		}
		println("upper_string(debug_get_level_string(msg_level)),': ',out")
	}
}

/**
 * Prints a debug message forced to decimal
 *
 * @param	msg_level	a char specifying the debug level of the message
 * @param	msg			a string containing the debug message to be printed as decimal
 */
define_function debug_dec(char msg_level, char msg[])
{
	stack_var long i,l;
	stack_var char c;
	stack_var char in[255];
	
	if (msg_level < DEBUG_ERROR || msg_level > DEBUG_MAX_LEVEL) {
		debug_msg(DEBUG_ERROR, "'invalid debug level specified - ', msg")
		return
	}
	if (msg_level <= debug_level) {
		in = msg
		l = LENGTH_STRING(in)
		println("'message length: ',itoa(l)")
		for (i = 1; i <= l; i++){
			c = GET_BUFFER_CHAR(in)
			println("'[',itoa(i),'] ',itoa(c)")
		}
	}
}


#end_if