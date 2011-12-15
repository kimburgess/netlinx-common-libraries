program_name='debug'
#if_not_defined __NCL_LIB_DEBUG
#define __NCL_LIB_DEBUG


include 'io'


define_constant
char DEBUG_OFF		= 0				// Available debug verbosity levels
char DEBUG_ERROR 	= 1
char DEBUG_WARN 	= 2
char DEBUG_INFO 	= 3

char DEBUG_LEVEL_STRINGS[4][16] = {
    'Off',
    'Error',
    'Warn',
    'Info'
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
	if (x >= DEBUG_OFF && x <= DEBUG_INFO) {
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
	if (msg_level < DEBUG_ERROR || msg_level > DEBUG_INFO) {
		debug_msg(DEBUG_ERROR, "'invalid debug level specified - ', msg")
		return
	}
    if (msg_level <= debug_level) {
		println("upper_string(debug_get_level_string(msg_level)),': ', msg")
    }
}

#end_if