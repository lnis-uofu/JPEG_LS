`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
`include "Encode_Regular_Mode_Under_Limit.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 7/26/2020
	DESCRIPTION: Top level module for regular mode encoding. Will determine which encoding conditons to use, either under limit or over limit encoding, depending on the calaculated unary
		     variable.
======================================================================================================================================================================================================
*/

module Encode_Regular_Mode #(parameter modresidual_length = `modresidual_length, k_length = `k_length, J_length = `J_length, unary_length = `unary_length,
				       mapped_error_value_length = `mapped_error_value_length, remaindervalue_length = `remaindervalue_length,
				       encodedpixel_width = `encodedpixel_width, encodedlength_width = `encodedlength_width)
		       (input [modresidual_length - 1:0] errValue, input B_N_Compare, input [k_length - 1:0] k, output reg [unary_length - 1:0] unary, 
			output reg [remaindervalue_length - 1:0] remainder_value_regular, output reg [encodedpixel_width - 1:0] encoded_pixel_regular, 
			output reg [encodedlength_width - 1:0] encoded_length_regular, output reg limit_overflow_regular);

/* 
======================================================================================================================================================================================================
	GENERALIZED PARAMETER DECLARATIONS
======================================================================================================================================================================================================
*/

	localparam [5:0] limit = 6'd32;
	localparam [3:0] qbpp = 4'd8;

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire temp;
	wire [modresidual_length - 1:0] absErrValue;
	wire [modresidual_length - 1:0] errValue_Plus_One;
	wire [modresidual_length - 1:0] errValue_Twos_Comp;

	wire [encodedpixel_width - 1:0] encoded_pixel_regular_under_limit;

	wire [mapped_error_value_length - 1:0] MErrval_subtract;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/

	reg [mapped_error_value_length - 1:0] MErrval;

/* 
======================================================================================================================================================================================================
	MODULE INSTANTIATION
======================================================================================================================================================================================================
*/

	Encode_Regular_Mode_Under_Limit Encode_Under_Limit (.MErrval(MErrval), .k(k), .encoded_regular_pixel_under_limit(encoded_pixel_regular_under_limit));

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	assign temp = ((k == 0) && B_N_Compare);

	assign absErrValue = (errValue[7]) ? ((~errValue) + 1) : errValue;

	assign MErrval_subtract = MErrval - 1;

	assign errValue_Plus_One = errValue + 1;
	assign errValue_Twos_Comp = ~errValue_Plus_One + 1;

	always @ (errValue or B_N_Compare or k or B_N_Compare or temp or encoded_pixel_regular_under_limit or MErrval_subtract) begin

		if (temp) begin
			if (errValue[modresidual_length - 1] != 1) MErrval = (errValue << 1) + 1;
			else MErrval = errValue_Twos_Comp << 1;
		end
		else	begin
			if (errValue[modresidual_length - 1] != 1) MErrval = (errValue << 1);
			else MErrval = (absErrValue << 1) - 1;
		end

		//May need to map to a barrel shifter from DW
		unary = MErrval >> k;
		if (unary < (limit - qbpp - 1)) begin
			limit_overflow_regular = 0;
			remainder_value_regular = 0; 
			encoded_pixel_regular = encoded_pixel_regular_under_limit;
			encoded_length_regular = unary + k + 1;
		end
		else begin
			limit_overflow_regular = 1;
			encoded_pixel_regular = 0;
			remainder_value_regular = {1'b1, MErrval_subtract[mapped_error_value_length - 2:0]};
			encoded_length_regular = 32;
		end

	end
endmodule

