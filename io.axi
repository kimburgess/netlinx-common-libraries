program_name='io'
#if_not_defined __NCL_LIB_IO
#define __NCL_LIB_IO


define_variable
persistent dev io_out = 0:0:0			// output stream device
persistent integer io_out_mtu = 131		// max characters to transmit (the
										// NL diagnositics console will only
										// display a max of 131 characters per
										// line)
persistent char io_line_seperator = $0A	// seperator to insert between lines


/**
 * Write a character array to the output device.
 *
 * If the outgoing data exceeds io_out_mtu it will be split into multiple
 * packets. If a non printable char is located within the last half of the
 * current packet it will split at the non printable character, otherwise all
 * data up to io_out_mtu will be sent in the packet.
 *
 * If io_out_mtu is 0 all data will be sent in a single packet.
 *
 * @param	buf		the character array to write
 * @param	offset	the offset to begin writing from (offset 0 == character 1)
 * @param	len		the number of characters to write
 */
define_function write(char buf[], integer offset, integer len)
{
	stack_var integer start
	stack_var integer end
	stack_var integer min_len

	if (io_out_mtu && len > io_out_mtu) {
		min_len = type_cast(io_out_mtu / 2)
		start = offset + 1
		while (start < offset + len) {
			end = min_value(start + io_out_mtu, offset + len)
			while (end > start + min_len) {
				if ((buf[end] > $08 && buf[end] < $0E) ||
					(buf[end] > $1B && buf[end] < $21)) {
					end++
					break
				}
				end--
			}

			if (end <= start + min_len) {
				end = min_value(start + io_out_mtu, offset + len + 1)
			}

			write(buf, start - 1, end - start)
			start = end
		}
	} else {
		send_string io_out, mid_string(buf, offset + 1, len)
	}
}

/**
 * Print a character array to the output stream.
 *
 * @param	x		a string containing the data to output
 */
define_function print(char x[])
{
	write(x, 0, length_string(x))
}

/**
 * Print a line to the output stream.
 *
 * @param	x		a string containing the data to output
 */
define_function println(char x[])
{
	write("x, io_line_seperator", 0, length_string(x))
}

#end_if