`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
`include "Encode_RI_Run_Encoding.v"
`include "Encode_RI_Without_Do_Run_Encoding.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 7/23/2020
	DESCRIPTION: Top level module for Run interruption mode encoding. Depending on input paramters, the encoding internal module output will be assigned to the top level modules output
		     depending on if the previous mode was a run mode (previous_mode == 1) or if the run interruption sequence also needs to encode the binary '0' and the J[Run Index]
		     bits of the run count variable.
======================================================================================================================================================================================================
*/

module Encode_RI_Mode #(parameter modresidual_length = `modresidual_length, k_length = `k_length, J_length = `J_length, unary_length = `unary_length, mapped_error_value_length = `mapped_error_value_length,
				  remaindervalue_length = `remaindervalue_length, encodedpixel_width = `encodedpixel_width, encodedlength_width = `encodedlength_width, N_Nn_Compare_length = `N_Nn_Compare_length, 
				  runcount_length = `runcount_length, mode_length = `mode_length)
		       (input [k_length - 1:0] k, input [modresidual_length - 1:0] errValue, input [N_Nn_Compare_length - 1:0] N_Nn_Compare, input RIType, input do_run_encoding,
			output reg [encodedpixel_width - 1:0] encoded_pixel_RI, output reg [encodedlength_width - 1:0] encoded_length_RI, output reg [unary_length - 1:0] unary_RI, 
			output reg limit_overflow_RI, output reg [remaindervalue_length - 1:0] remainder_value_RI, input [J_length - 1:0] J, input [J_length - 1:0] J_Comp,
			input [J_length - 1:0] J_Recurring_Mode_Two, input [mode_length - 1:0] previous_mode);

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/


	wire [encodedlength_width - 1:0] encoded_length_without_do_run_encoding;
	wire [encodedlength_width - 1:0] encoded_length_with_do_run_encoding;

	wire [encodedpixel_width - 1:0] encoded_pixel_without_do_run_encoding;
	wire [encodedpixel_width - 1:0] encoded_pixel_with_do_run_encoding;

	wire limit_overflow_with_do_run_encoding;
	wire limit_overflow_without_do_run_encoding;

	wire [remaindervalue_length - 1:0] remainder_value_without_do_run_encoding;
	wire [remaindervalue_length - 1:0] remainder_value_with_do_run_encoding;

	wire [modresidual_length - 1:0] absErrValue;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/

	reg map;
	reg [mapped_error_value_length - 1:0] MErrval_RI;

/* 
======================================================================================================================================================================================================
	MODULE INSTANTIATION
======================================================================================================================================================================================================
*/

	Encode_RI_Run_Encoding RI_Run_Encoding (.MErrval_RI(MErrval_RI), .unary(unary_RI), .encoded_length(encoded_length_with_do_run_encoding),
						.encoded_pixel(encoded_pixel_with_do_run_encoding), .k(k), .J(J), .J_Comp(J_Comp), .J_Recurring_Mode_Two(J_Recurring_Mode_Two),
						.limit_overflow(limit_overflow_with_do_run_encoding), .remainder_value(remainder_value_with_do_run_encoding), .previous_mode(previous_mode));
	Encode_RI_Without_Do_Run_Encoding RI_Non_Run_Encoding (.MErrval_RI(MErrval_RI), .unary(unary_RI), .encoded_length(encoded_length_without_do_run_encoding), 
							       .remainder_value(remainder_value_without_do_run_encoding), .encoded_pixel(encoded_pixel_without_do_run_encoding), .k(k),
							       .J(J), .limit_overflow(limit_overflow_without_do_run_encoding));

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	assign absErrValue = (errValue[modresidual_length - 1]) ? ((~errValue) + 1) : errValue;


	always @ (k or errValue or N_Nn_Compare or encoded_pixel_without_do_run_encoding or encoded_pixel_with_do_run_encoding or do_run_encoding or RIType or 
		 encoded_length_with_do_run_encoding or encoded_length_without_do_run_encoding or limit_overflow_without_do_run_encoding or 
		 limit_overflow_with_do_run_encoding or remainder_value_with_do_run_encoding or remainder_value_without_do_run_encoding) begin

		if ((k == 0) && (errValue[modresidual_length - 1] != 1) && (errValue > 0) && (N_Nn_Compare == 0)) map = 1;
		else if ((errValue[modresidual_length - 1] == 1) && (N_Nn_Compare == 1)) map = 1;
		else if ((errValue[modresidual_length - 1] == 1) && (k !=0)) map = 1;
		else map = 0;
	
		MErrval_RI = (absErrValue << 1) - RIType - map;

		unary_RI = MErrval_RI >> k;

		// in do_run_encoding case we need to encode just the (runlen,J) value since there will
		// be no hits
		if(do_run_encoding) begin
			encoded_pixel_RI = encoded_pixel_with_do_run_encoding;
			remainder_value_RI = remainder_value_with_do_run_encoding;
			limit_overflow_RI = limit_overflow_with_do_run_encoding;
			encoded_length_RI = encoded_length_with_do_run_encoding;
		end
		else begin
			encoded_pixel_RI = encoded_pixel_without_do_run_encoding;
			remainder_value_RI = remainder_value_without_do_run_encoding;
			limit_overflow_RI = limit_overflow_without_do_run_encoding;
			encoded_length_RI = encoded_length_without_do_run_encoding;
		end
	end
endmodule