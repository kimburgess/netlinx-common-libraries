program_name='test_string'
#if_not_defined __NCL_LIB_TEST_STRING
#define __NCL_LIB_TEST_STRING

include 'string'
include 'io'
include 'test_utils'


define_constant
	long TEST_STRING_ITERATIONS = 100	// number of times to execute each
										// test for speed testing

define_function char test_string_get_between(char a[],
		char left[], char right[]) 
{
	stack_var long i
	
	println("'Running string_get_between(',a, ',',left,', ',right,')'")
	test_timer_start()
	for (i = TEST_STRING_ITERATIONS; i; i--) {
		string_get_between(a, left, right)
	}
	test_timer_stop(TEST_STRING_ITERATIONS)
	return test_end()
}

define_function char test_string_ci_get_between(char a[],
		char left[], char right[])
{
	stack_var long i
	
	println("'Running string_ci_get_between(',a, ',',left,', ',right,')'")
	test_timer_start()
	for (i = TEST_STRING_ITERATIONS; i; i--) {
		string_ci_get_between(a, left, right)
	}
	test_timer_stop(TEST_STRING_ITERATIONS)
	return test_end()
}

/**
 * Test functionality of some string functions
 */
define_function test_string()
{
	println("':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'")
	println("'Running string library test suite.'")
	println("' '")
	test_string_get_between('http://site.com/', 'http://', '/')
	test_string_ci_get_between('http://site.com/', 'HTTP://', '/')
}

#end_if