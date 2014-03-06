program_name='test_array'

#if_not_defined __NCL_LIB_TEST_ARRAY
#define __NCL_LIB_TEST_ARRAY

#include 'io'
#include 'array'

define_device
	dev1 	= 5001:1:3;
	dev2	= 5001:2:3;
	dev3	= 5001:3:3;
	dev4	= 5001:4:3;
	dev5	= 5001:5:3;
	
	

define_variable
	dev 	devices[5] 	= { dev1, dev2, dev3, dev4, dev5}
	dev 	devS		= 5001:1:3;
	integer integers[5]	= {10,20,30,40,50}
	double 	doubles[5] 	= {10.1,20.2,30.3,40.4,50.5}
	char	strings[5][5]={'foo','bar','baz','qux','quux'}
	
/**
 * Test functionality of some array functions
 */

define_function test_array()
{
	println("':::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'")
	println("'Running array library test suite.'")
	println("' '")
	println("'Devices = {5001:1:3, 5001:2:3, 5001:3:3, 5001:4:3, 5001:5:3}'")
	println("'Searching index of 5001:1:3'")
	println("itoa(array_device_index(devS, devices))")
	println("'Searching index of 1001:1:0'")
	println("itoa(array_device_index(1001:1:1, devices))")
	println("'Searching index of 5001:1:3 using deprecated function'")
	println("itoa(array_index(devS, devices))")
	
	println("' '")
	println("'integers = {10,20,30,40,50}'")
	println("'Searching index of 20'")
	println("itoa(array_integer_index(20, integers))")
	println("'Searching index of 200'")
	println("itoa(array_integer_index(200, integers))")
	
	println("' '")
	println("'doubles = {10.1,20.2,30.3,40.4,50.5}'")
	println("'Searching index of 30.3'")
	println("itoa(array_double_index(30.3, doubles))")
	println("'Searching index of 30.33'")
	println("itoa(array_double_index(30.33, doubles))")
	
	println("' '")
	println("'strings = {''foo'',''bar'',''baz'',''qux'',''quux''}'")
	println("'Searching index of qux'")
	println("itoa(array_string_index("'qux'", strings))")
	println("'Searching index of fo'")
	println("itoa(array_string_index("'fo'", strings))")
	
}

#end_if