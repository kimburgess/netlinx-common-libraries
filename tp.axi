PROGRAM_NAME='tp'
#if_not_defined __NCL_LIB_TP
#define __NCL_LIB_TP
/******************************************************************************
Include File: tp.axi
Provides common touch panel functionality

Provided by Vanti <www.vanti.co.uk>
******************************************************************************/
#include 'math'

define_function send_tp_command(dev panel, char cmd[]){
	debug_msg(DEBUG_INFO,"'PANEL[',panel.number,':',panel.port,':',panel.system,']: ',cmd");
	send_command panel,"cmd";
}
define_function m_send_tp_command(dev panels[], char cmd[]){
	debug_msg(DEBUG_INFO,"'PANELS: ',cmd");
	send_command panels,"cmd";
}

define_function update_text(dev panel, integer textAddress, char text[]){
	send_tp_command(panel, "'^TXT-',itoa(textAddress),',0,',text");
}
define_function m_updateText(dev panels[], integer textAddress, char text[]){
	m_send_tp_command(panels, "'^TXT-',itoa(textAddress),',0,',text");
}
define_function update_off_text(dev panel, integer textAddress, char text[]){
	send_tp_command(panel, "'^TXT-',itoa(textAddress),',1,',text");
}
define_function update_on_text(dev panel, integer textAddress, char text[]){
	send_tp_command(panel, "'^TXT-',itoa(textAddress),',2,',text");
}

define_function update_fader(dev panel, integer fader, integer lev){
	send_level panel, fader, lev;
}
define_function m_update_fader(dev panels[], integer fader, integer lev){
	send_level panels, fader, lev;
}

define_function show_page(dev panel, char pageName[]){
	send_tp_command(panel,"'PAGE-',pageName");
}

define_function show_popup(dev panel, char popupName[]){
	send_tp_command(panel,"'@PPN-',popupName");
}

define_function hide_popup(dev panel, char popupName[]){
	send_tp_command(panel,"'@PPK-',popupName");
}
define_function hide_all_popups(dev panel){
	send_tp_command(panel,"'@PPX'");
}

define_function disable_button(dev panel, char textAddress[]){
	send_tp_command(panel,"'^ENA-',textAddress,',0'");
}
define_function enable_button(dev panel, char textAddress[]){
	send_tp_command(panel,"'^ENA-',textAddress,',1'");
}

define_function hide_button(dev panel, char textAddress[]){
	send_tp_command(panel,"'^SHO-',textAddress,',0'");
}
define_function m_hide_button(dev panels[], char textAddress[]){
	m_send_tp_command(panels,"'^SHO-',textAddress,',0'");
}
define_function show_button(dev panel, char textAddress[]){
	send_tp_command(panel,"'^SHO-',textAddress,',1'");
}
define_function m_show_button(dev panels[], char textAddress[]){
	m_send_tp_command(panels,"'^SHO-',textAddress,',1'");
}

define_function size_button(dev panel, char textAddress[],integer left,integer top,integer width,integer height){
	send_tp_command(panel,"'^BSP-',textAddress,',',itoa(left),',',itoa(top),',',itoa(left+width),',',itoa(top+height)");
}

define_function set_button_state(dev panel, char textAddress[], integer state){
	send_tp_command(panel,"'^ANI-',textAddress,',',itoa(state),',',itoa(state),',1'");
}

define_function update_button_fill(dev panel, integer btn, integer rgb[3]){
	stack_var char r[2],g[2],b[2];
	r = itohex(rgb[1]);
	if(length_string(r)<2){
		r="'0',r";
	}
	g = itohex(rgb[2]);
	if(length_string(g)<2){
		g="'0',g";
	}
	b = itohex(rgb[3]);
	if(length_string(b)<2){
		b="'0',b";
	}
	send_command panel, "'^BCF-',itoa(btn),',0,#',r,g,b,'FF'";
}

define_function position_fader_handle(dev tp, integer handleChannel, integer value, double max, integer faderHeight, integer left_offset, integer top_offset, integer handleWidth, integer handleHeight){
	stack_var double p_val;
	stack_var double scaled_val;
	stack_var integer y;
	
	p_val = ( max - value) / max;
	scaled_val = round(faderHeight * p_val);
	y = atoi(ftoa(top_offset + scaled_val - handleHeight/2));
	
	size_button(tp, "itoa(handleChannel)", left_offset, y, handleWidth, handleHeight);
}
define_function position_fader_handle_horizontal(dev tp, integer handleChannel, integer value, double max, integer faderWidth, integer left_offset, integer top_offset, integer handleWidth, integer handleHeight){
	stack_var double p_val;
	stack_var double scaled_val;
	stack_var integer left;
	
	p_val = value / max;
	scaled_val = round(faderWidth * p_val);
	left = atoi(ftoa(left_offset + scaled_val - handleWidth/2));
	
	size_button(tp, "itoa(handleChannel)", left, top_offset, handleWidth, handleHeight);
}
define_function position_fader_handle_inverse(dev tp, integer handleChannel, integer value, double max, integer faderHeight, integer left_offset, integer top_offset, integer handleWidth, integer handleHeight){
	stack_var double p_val, scaled_val;
	stack_var integer y;
	
	p_val = value / max;
	scaled_val = round(faderHeight * p_val);
	y = atoi(ftoa(top_offset + scaled_val - handleHeight/2));
	
	size_button(tp, "itoa(handleChannel)", left_offset, y, handleWidth, handleHeight);
}

#end_if