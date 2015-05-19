/**
 * UNIX Timestamp functions for AMX NetLinx
 * Copyright (c) 2010, true
 * amx at trueserve dot org
 *
 * This implementation relies on newer firmwares with clkmgr set up
 * properly. Check your timezone settings for correct operation.
 *
 * To remove clkmgr support, set unixtime_utc_offset_* manually,
 * and comment or remove calls to unixtime_sync_with_clkmgr() in
 * define_start, define_program, and the timeline_event, and define your
 * offset from UST in the unixtime_utc_offset_* variables.
 *
 * Known Bugs and Limitations:
 *  - DST is fixed at +1h. This will be changed in the future.
 *  - DST being active isn't checked properly.
 *  - Compiler gives warnings for some operations with slongs being longs?
 *      Fixed with stack_vars.
 *  * Negative values aren't supported in this version. Don't try it.
 *      Epoch-2038 only...
*/

program_name='unixtime'
#if_not_defined __NCL_LIB_UNIXTIME
#define __NCL_LIB_UNIXTIME

/*
 * REQUIRES STRING LIBRARY
 */
include 'String.axi'


/* constants */
define_constant
long	UNIXTIME_TL							= 3851134

slong	UNIXTIME_SECONDS_PER_YEAR			= 31536000
slong	UNIXTIME_SECONDS_PER_MONTH[12]		= {
	2678400, 2419200, 2678400, 2592000, 2678400, 2592000,
	2678400, 2678400, 2592000, 2678400, 2592000, 2678400
}
slong	UNIXTIME_SECONDS_PER_WEEK			= 604800
slong	UNIXTIME_SECONDS_PER_DAY			= 86400
slong	UNIXTIME_SECONDS_PER_HOUR			= 3600
slong	UNIXTIME_SECONDS_PER_MINUTE			= 60

integer	UNIXTIME_DAYS_PER_MONTH[12]			= {
	31, 28, 31, 30, 31, 30,
	31, 31, 30, 31, 30, 31
}
integer	UNIXTIME_DAYS_MONTH_OFFSET[12]		= {		// unused, may be used later for performance
	31, 59, 90, 120, 151, 181,
	212, 243, 273, 304, 334, 365
}
integer	UNIXTIME_DAYS_MONTH_OFFSET_YL[12]	= {		// unused, may be used later for performance
	31, 60, 91, 121, 152, 182,
	213, 244, 274, 305, 335, 366
}

UNIXTIME_DAYS_TEXT_3[7][3] 					= {		// fmt_date() stuff
	'Sun',
	'Mon',
	'Tue',
	'Wed',
	'Thu',
	'Fri',
	'Sat'
}
UNIXTIME_DAYS_TEXT_FULL[7][9] 				= {
	'Sunday',
	'Monday',
	'Tuesday',
	'Wednesday',
	'Thursday',
	'Friday',
	'Saturday'
}
UNIXTIME_MONTH_TEXT_3[12][3] 				= {
	'Jan',
	'Feb',
	'Mar',
	'Apr',
	'May',
	'Jun',
	'Jul',
	'Aug',
	'Sep',
	'Oct',
	'Nov',
	'Dec'
}
UNIXTIME_MONTH_TEXT_FULL[12][9] 			= {
	'January',
	'February',
	'March',
	'April',
	'May',
	'June',
	'July',
	'August',
	'September',
	'October',
	'November',
	'December'
}


/* variables */
define_variable
volatile long		unixtime_tl_times[1] = {60000}

volatile char		unixtime_work[10]

volatile slong	 	unixtime_utc_offset_hr
volatile slong	 	unixtime_utc_offset_min


/* start */
define_start
{
	// sync
	unixtime_sync_with_clkmgr()

	// check for updates every minute
	timeline_create(UNIXTIME_TL, unixtime_tl_times, 1,
			TIMELINE_ABSOLUTE, TIMELINE_REPEAT)
}


/* events */
define_event
timeline_event[UNIXTIME_TL] {
	// sync
	unixtime_sync_with_clkmgr()
}


/* functions */
/**
 * Returns a unix timestamp sourced from AMX-style date and time strings
 * with the assumption that said strings are CST+0:00.
 *
 * @param	d		date in AMX "LDATE" format
 * @param	t		time in AMX "TIME" format
 * @return			a unix timestamp
 */
define_function slong unixtime_utc(char d[10], char t[8])
{
	return unixtime_offset(d, t, 0)
}

/**
 * Returns a unix timestamp sourced from AMX-style date and time strings
 * with the assumption that said strings are in the current timezone.
 *
 * @param	d		date in AMX "LDATE" format
 * @param	t		time in AMX "TIME" format
 * @return			a unix timestamp
 */
define_function slong unixtime_now()
{
	return unixtime(LDATE, TIME)
}

/**
 * Returns a unix timestamp sourced from AMX-style date and time strings
 * with the assumption that said strings are in the current timezone.
 *
 * @param	d		date in AMX "LDATE" format
 * @param	t		time in AMX "TIME" format
 * @return			a unix timestamp
 */
define_function slong unixtime(char d[10], char t[8])
{
	return unixtime_offset(d, t,
			(0 - ((unixtime_utc_offset_hr * 3600) +
			(unixtime_utc_offset_min * 60))))
}

/**
 * Returns a unix timestamp sourced from AMX-style date and time strings
 * using a specified timezone offset.
 *
 * @param	d		date in AMX "LDATE" format
 * @param	t		time in AMX "TIME" format
 * @param	offset	time offset in seconds
 * @return			a unix timestamp
 */
define_function slong unixtime_offset(char d[10], char t[8], slong offset)
{
	stack_var slong ret
	stack_var integer i
	stack_var slong work

	/*** DATE ***/
	// do years
	work = UNIXTIME_SECONDS_PER_YEAR
	ret = work * (type_cast(date_to_year(d)) - 1970)

	// add seconds for prior leapyears
	work = UNIXTIME_SECONDS_PER_DAY
	for (i = type_cast(date_to_year(d)) - 1; i >= 1972; i--) {
		if (unixtime_year_is_leapyear(i)) {
			ret = ret + work
		}
	}

	// add seconds for months
	for (i = type_cast(date_to_month(d)) - 1; i >= 1; i--) {
		work = UNIXTIME_SECONDS_PER_MONTH[i]
		ret = ret + work
	}

	// add a day due to this year being a leapyear?
	work = date_to_year(d)
	if (unixtime_year_is_leapyear(type_cast(work))) {
		if (date_to_month(d) >= 3) {
			work = UNIXTIME_SECONDS_PER_DAY
			ret = ret + work
		}
	}

	// add seconds for days
	work = UNIXTIME_SECONDS_PER_DAY
	for (i = type_cast(date_to_day(d)); i > 1; i--) {
		ret = ret + work
	}

	/*** TIME ***/
	work = UNIXTIME_SECONDS_PER_HOUR
	ret = ret + (work * time_to_hour(t))

	work = UNIXTIME_SECONDS_PER_MINUTE
	ret = ret + (work * time_to_minute(t))

	ret = ret + time_to_second(t)

	// apply offset
	ret = ret + offset

	return ret
}

/**
 * Converts a unix timestamp to an AMX-style "TIME".
 *
 * @param	u		timestamp to conver to AMX-style "TIME"
 * @return			an AMX-style "TIME" string
 */
define_function char[8] unixtime_to_netlinx_time(slong u)
{
	return fmt_date('H:i:s', u)
}

/**
 * Converts a unix timestamp to an AMX-style "DATE".
 *
 * @param	u		timestamp to conver to AMX-style "DATE"
 * @return			an AMX-style "DATE" string
 */
define_function char[8] unixtime_to_netlinx_date(slong u)
{
	return fmt_date('m-d-y', u)
}

/**
 * Converts a unix timestamp to an AMX-style "LDATE".
 *
 * @param	u		timestamp to conver to AMX-style "LDATE"
 * @return			an AMX-style "LDATE" string
 */
define_function char[10] unixtime_to_netlinx_ldate(slong u)
{
	return fmt_date('m-d-Y', u)
}

/**
 * Returns a formatted string similar to and supporting most of
 * the functionality of php's date() function.
 *
 * @param	fmt		format specifier string
 * @param	u		the unix timestamp to use
 * @return			a formatted string
 */
define_function char[STRING_RETURN_SIZE_LIMIT] fmt_date(char fmt[1024], slong u)
{
	stack_var integer	i
	stack_var char		ret[STRING_RETURN_SIZE_LIMIT + 1]

	stack_var integer	work

	stack_var char		amx_ldate[10]
	stack_var char		amx_time[8]

	stack_var integer	dat[7]	// hr, m, s, m, d, y, days

	unixtime_to_raw_values(u, dat[1], dat[2], dat[3],
				dat[4], dat[5], dat[6], dat[7])

	amx_ldate = "string_prefix_to_length(itoa(dat[4]), '0', 2), '-',		// some functions are easier using built-in
					string_prefix_to_length(itoa(dat[5]), '0', 2), '-',		// amx stuff
					string_prefix_to_length(itoa(dat[6]), '0', 4)"

	amx_time = "string_prefix_to_length(itoa(dat[1]), '0', 2), ':',
					string_prefix_to_length(itoa(dat[2]), '0', 2), ':',
					string_prefix_to_length(itoa(dat[3]), '0', 2)"

	for (i = 1; i <= length_string(fmt); i++) {								// parse date
		switch (fmt[i]) {
			case '\': {		// escape
				i++
				if (i <= length_string(fmt)) {
					ret = "ret, fmt[i]"
				}
			}
			case ' ': {		// space is common so escape
				ret = "ret, fmt[i]"
			}

			/*** DAY ***/
			case 'd': {		// day, leading zero
				ret = "ret, string_prefix_to_length(itoa(dat[5]), '0', 2)"
			}
			case 'D': {		// day of week, 3 chars
				ret = "ret, UNIXTIME_DAYS_TEXT_3[type_cast(day_of_week(amx_ldate))]"
			}
			case 'j': {		// day with no leading digits
				ret = "ret, itoa(dat[5])"
			}
			case 'l': {		// day of week, full string
				ret = "ret, UNIXTIME_DAYS_TEXT_FULL[type_cast(day_of_week(amx_ldate))]"
			}
			case 'N': {		// day of week, 1 = mon, 7 = sun
				work = (type_cast(day_of_week(amx_ldate)) % 7) + 1
				if (work == 0)
					work = 7
				ret = "ret, itoa(work)"
			}
			case 'S': {		// ordinal suffix (st, nd, rd, th)
				switch (dat[5]) {
					case 1:
					case 21:
					case 31:
						ret = "ret, 'st'"
					case 2:
					case 22:
						ret = "ret, 'nd'"
					case 3:
					case 23:
						ret = "ret, 'rd'"
					default:
						ret = "ret, 'th'"
				}
			}
			case 'w': {		// day of week, 0 = sunday, 6 = saturday
				ret = "ret, itoa(day_of_week(amx_ldate) - 1)"
			}
			case 'z': {		// day of year, 0-indexed
				ret = "ret, itoa(dat[7] - 1)"
			}

			/*** WEEK ***/
			case 'W': {		// week number
				ret = "ret, 'W-UNIMPLEMENTED'"
			}


			/*** MONTH ***/
			case 'F': {		// month, full string
				ret = "ret, UNIXTIME_MONTH_TEXT_FULL[type_cast(date_to_month(amx_ldate))]"
			}
			case 'm': {		// month, leading zero
				ret = "ret, string_prefix_to_length(itoa(dat[4]), '0', 2)"
			}
			case 'M': {		// month, 3 chars
				ret = "ret, UNIXTIME_MONTH_TEXT_3[type_cast(date_to_month(amx_ldate))]"
			}
			case 'n': {		// month with no leading digits
				ret = "ret, itoa(dat[4])"
			}
			case 't': {		// number of days in month
				switch (dat[4]) {
					case 1:
					case 3:
					case 5:
					case 7:
					case 8:
					case 10:
					case 12:
						ret = "ret, '31'"
					case 4:
					case 6:
					case 9:
					case 11:
						ret = "ret, '30'"
					case 2: {
						if (unixtime_year_is_leapyear(dat[6])) {
							ret = "ret, '29'"
						} else {
							ret = "ret, '28'"
						}
					}
				}
			}

			/*** YEAR ***/
			case 'L': {		// is leap year?
				ret = "ret, itoa(unixtime_year_is_leapyear(dat[6]))"
			}
			case 'o': {
				ret = "ret, 'o-UNIMPLEMENTED'"
			}
			case 'Y': {
				ret = "ret, itoa(dat[6])"
			}
			case 'y': {
				ret = "ret, right_string(itoa(dat[6]), 2)"
			}

			/*** TIME ***/
			case 'a': {		// lowercase am/pm
				if (dat[1] < 12) {
					ret = "ret, 'am'"
				} else {
					ret = "ret, 'pm'"
				}
			}
			case 'A': {		// uppercase am/pm
				if (dat[1] < 12) {
					ret = "ret, 'AM'"
				} else {
					ret = "ret, 'PM'"
				}
			}
			case 'B': {		// internet swatch time (only geeks use this =])
				ret = "ret, 'B-UNIMPLEMENTED'"
			}
			case 'g': {		// 12-hour hour without leading zero
				if (dat[1] == 0) {
					ret = "ret, '12'"
				} else if (dat[1] >= 1 && dat[1] <= 12) {
					ret = "ret, itoa(dat[1])"
				} else {
					ret = "ret, itoa(dat[1] - 12)"
				}
			}
			case 'G': {		// 24-hour hour without leading zero
				ret = "ret, itoa(dat[1])"
			}
			case 'h': {		// 12-hour hour with leading zero
				if (dat[1] == 0) {
					ret = "ret, '12'"
				} else if (dat[1] >= 1 && dat[1] <= 12) {
					ret = "ret, string_prefix_to_length(itoa(dat[1]), '0', 2)"
				} else {
					ret = "ret, string_prefix_to_length(itoa(dat[1] - 12), '0', 2)"
				}
			}
			case 'H': {		// 24-hour hour with leading zero
				ret = "ret, string_prefix_to_length(itoa(dat[1]), '0', 2)"
			}
			case 'i': {		// minutes with leading zero
				ret = "ret, string_prefix_to_length(itoa(dat[2]), '0', 2)"
			}
			case 's': {		// seconds with leading zero
				ret = "ret, string_prefix_to_length(itoa(dat[3]), '0', 2)"
			}
			case 'u': {		// microseconds - unimplemented but just returns '0'
				ret = "ret, '0'"
			}

			/*** TIMEZONE ***/
			// nothing from timezone is implemented

			/*** FULL DATE/TIME ***/
			case 'c': {		// ISO8601 date
				ret = "ret, string_prefix_to_length(itoa(dat[6]), '0', 4), '-',
							string_prefix_to_length(itoa(dat[4]), '0', 2), '-',
							string_prefix_to_length(itoa(dat[5]), '0', 2), 'T',
							string_prefix_to_length(itoa(dat[1]), '0', 2), ':',
							string_prefix_to_length(itoa(dat[2]), '0', 2), ':',
							string_prefix_to_length(itoa(dat[3]), '0', 2), '+00:00'"
			}
			case 'r': {		// RFC 2822 date
				ret = "ret, ' ', UNIXTIME_DAYS_TEXT_3[type_cast(day_of_week(amx_ldate))],
							', ', string_prefix_to_length(itoa(dat[4]), '0', 2), ' ',
							UNIXTIME_MONTH_TEXT_3[type_cast(date_to_month(amx_ldate))], ' ',
							string_prefix_to_length(itoa(dat[6]), '0', 4), ' ',
							string_prefix_to_length(itoa(dat[1]), '0', 2), ':',
							string_prefix_to_length(itoa(dat[2]), '0', 2), ':',
							string_prefix_to_length(itoa(dat[3]), '0', 2), ' +0000'"
			}
			case 'U': {
				ret = "ret, itoa(u)"
			}

			// nothing matches, so just print it
			default: {
				ret = "ret, fmt[i]"
			}
		}
	}

	return ret
}

/**
 * Modifies some raw values, such as hours, minutes, seconds, month, etc.
 * from the specified timestamp.
 *
 * @param	u		the unix timestamp to use
 * @param	hr		hours
 * @param	min		minutes
 * @param	sec		seconds
 * @param	month	month
 * @param	dy		day
 * @param	yr		year
 * @param	days	amount of days since the beginning of the year
 */
define_function unixtime_to_raw_values(slong u, integer hr, integer minute, integer sec,
				integer month, integer dy, integer yr, integer days)
{
	stack_var integer	i
	stack_var slong		j

	stack_var slong		w
	stack_var slong		w2

	// set working unit so we don't modify u
	w = u

	yr = 1970
	while (w >= w2) {
		yr++

		w2 = UNIXTIME_SECONDS_PER_YEAR
		w = w - w2

		// remove leap day if applicable
		if (unixtime_year_is_leapyear(yr)) {
			w2 = UNIXTIME_SECONDS_PER_DAY
			w = w - w2
		}
	}

	days = 1
	w2 = UNIXTIME_SECONDS_PER_DAY
	while (w >= w2) {
		days++
		w = w - w2
	}

	month = 1
	dy = 0

	j = days
	for (i = 1; i <= 12; i++) {
		w2 = UNIXTIME_DAYS_PER_MONTH[i]
		j = j - w2
		if (i == 2) {
			// test for leapyear
			if (unixtime_year_is_leapyear(yr)) {
				j--
			}
		}

		if (j > 0) {
			month++
		} else {
			w2 = j + UNIXTIME_DAYS_PER_MONTH[i]
			dy = dy + type_cast(w2)

			// test for leapyear
			if (unixtime_year_is_leapyear(yr)) {
				dy++
			}

			if (dy > UNIXTIME_DAYS_PER_MONTH[i]) {
				dy = dy - UNIXTIME_DAYS_PER_MONTH[i]
			}
			break
		}
	}

	hr = 0
	w2 = UNIXTIME_SECONDS_PER_HOUR
	while (w >= UNIXTIME_SECONDS_PER_HOUR) {
		hr++
		w = w - w2
	}

	minute = 0
	w2 = UNIXTIME_SECONDS_PER_MINUTE
	while (w >= UNIXTIME_SECONDS_PER_MINUTE) {
		minute++
		w = w - w2
	}

	sec = type_cast(w)
}

/**
 * Returns true if the year specified is a leap year.
 *
 * @param	year		the year to check
 * @return				value indicating if the year is a leap year or not
 */
define_function char unixtime_year_is_leapyear(integer year)
{
	if (year % 4 == 0) {
		if (year % 100 != 0 || year % 400 == 0) {
			return 1
		}
	}

	return 0
}

/**
 * Sets UTC offsets based on NetLinx clkmgr.
 */
define_function unixtime_sync_with_clkmgr()
{
	stack_var char work[10]

	work = clkmgr_get_timezone()

	if (work[4] == '+') {
		unixtime_utc_offset_hr = atoi(mid_string(work, 5, 2))
		unixtime_utc_offset_min = atoi(mid_string(work, 8, 2))
	} else {
		unixtime_utc_offset_hr = atoi(mid_string(work, 5, 2))
		unixtime_utc_offset_min = atoi(mid_string(work, 8, 2))

		unixtime_utc_offset_hr = 0 - unixtime_utc_offset_hr
		unixtime_utc_offset_min = 0 - unixtime_utc_offset_min
	}

	// adjust for dst (currently fixed at +1h, this will be fixed later) // TODO: BROKEN, FIX ME
	if (clkmgr_is_daylightsavings_on()) {
		unixtime_utc_offset_hr++
	}
}

/**
 * Returns true if daylight savings time is currently active.
 *
 * @todo	Only supports occurance right now. Doesn't support fixed yet.
 *
 * @return				value indicating if DST is currently being observed
 */
define_function integer clkmgr_is_daylightsavings_active()
{
	stack_var char dst_start[80]
	stack_var char dst_end[80]
	stack_var integer stage

	stack_var integer week_now
	stack_var integer day_now

	stack_var char work[10][12]

	week_now = date_get_week_of_month(LDATE)
	day_now = type_cast(day_of_week(LDATE))

	dst_start = clkmgr_get_start_daylightsavings_rule()
	dst_end = clkmgr_get_end_daylightsavings_rule()

	stage = 0

	if (remove_string(dst_start, ':', 1) == 'fixed:') {

	} else {
		explode_quoted(',', dst_start, work, 10, '"')
		if (date_to_month(LDATE) > atoi(work[3])) {
			stage = 1
		} else if (date_to_month(LDATE) == atoi(work[3])) {
			if (week_now > atoi(work[2])) {
				stage = 1
			} else if (week_now == atoi(work[2])) {
				if (day_now >= atoi(work[1])) {
					stage = 1
				}
			}
		}
	}

	if (stage != 1) {
		return 0
	}

	if (remove_string(dst_end, ':', 1) == 'fixed:') {

	} else {
		explode_quoted(',', dst_end, work, 10, '"')
		if (date_to_month(LDATE) < atoi(work[3])) {
			return 1
		} else if (date_to_month(LDATE) == atoi(work[3])) {
			if (week_now < atoi(work[2])) {
				return 1
			} else if (week_now == atoi(work[3])) {
				if (day_now < atoi(work[1])) {
					return 1
				}
			}
		}
	}

	return 0
}

define_function integer date_get_week(char ld[10])
{
	stack_var integer d[3]
	stack_var integer w[2]
	stack_var integer work
	stack_var integer ret

	d[1] = type_cast(date_to_day(ld))
	d[2] = type_cast(date_to_month(ld))

	w[1] = 1
	w[2] = 1

	work = type_cast(day_of_week("'01/01/', itoa(type_cast(date_to_year(LDATE)))"))
	ret = 1

	while (w[1] != d[1] && w[2] != d[2]) {
		work++
		if (work > 7) {
			work = 1
			ret++
		}

		w[1]++
		switch (w[2]) {
			case 2: {
				if (unixtime_year_is_leapyear(type_cast(date_to_year(ld)))) {
					if (w[1] > 29) {
						w[1] = 1
						w[2]++
					}
				} else {
					if (w[1] > 28) {
						w[1] = 1
						w[2]++
					}
				}
			}
			case 4:
			case 6:
			case 9:
			case 11: {
				if (w[1] > 30) {
					w[1] = 1
					w[2]++
				}
			}
			default: {
				if (w[1] > 31) {
					w[1] = 1
					w[2]++
				}
			}
		}
	}

	return ret
}

define_function integer date_get_week_of_month(char ld[10])
{
	stack_var integer d[3]
	stack_var integer w[2]
	stack_var integer work
	stack_var integer ret

	d[1] = type_cast(date_to_day(ld))
	d[2] = type_cast(date_to_month(ld))

	w[1] = 1
	w[2] = 1

	work = type_cast(day_of_week("'01/01/', itoa(type_cast(date_to_year(LDATE)))"))
	ret = 1

	while (w[1] != d[1] && w[2] != d[2]) {
		work++
		if (work > 7) {
			work = 1
			ret++
		}

		w[1]++
		switch (w[2]) {
			case 2: {
				if (unixtime_year_is_leapyear(type_cast(date_to_year(ld)))) {
					if (w[1] > 29) {
						w[1] = 1
						w[2]++
						ret = 1
					}
				} else {
					if (w[1] > 28) {
						w[1] = 1
						w[2]++
						ret = 1
					}
				}
			}
			case 4:
			case 6:
			case 9:
			case 11: {
				if (w[1] > 30) {
					w[1] = 1
					w[2]++
					ret = 1
				}
			}
			default: {
				if (w[1] > 31) {
					w[1] = 1
					w[2]++
					ret = 1
				}
			}
		}
	}

	return ret
}

#end_if