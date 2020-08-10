`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 7/23/2020
	DESCRIPTION: This module will encode the the run interruption sequence according to ITU T.87.
======================================================================================================================================================================================================
*/

module Encode_RI_Without_Do_Run_Encoding #(parameter modresidual_length = `modresidual_length, k_length = `k_length, mode_length = `mode_length, J_length = `J_length, unary_length = `unary_length, mapped_error_value_length = `mapped_error_value_length,
				 		     remaindervalue_length = `remaindervalue_length, encodedpixel_width = `encodedpixel_width, encodedlength_width = `encodedlength_width, N_Nn_Compare_length = `N_Nn_Compare_length, runcount_length = `runcount_length)
			   	          (input [mapped_error_value_length - 1:0] MErrval_RI, input [unary_length - 1:0] unary, input [k_length - 1:0] k, output reg [encodedpixel_width - 1:0] encoded_pixel,
					   output reg [encodedlength_width - 1:0] encoded_length, output reg limit_overflow, input [J_length - 1:0] J, output reg [remaindervalue_length - 1:0] remainder_value);
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

	wire [mapped_error_value_length - 1:0] MErrval_RI_subtract;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/

	reg already_appended_one_1;
	reg already_appended_one_2;
	reg already_appended_one_3;
	reg already_appended_one_4;
	reg already_appended_one_5;
	reg already_appended_one_6;
	reg already_appended_one_7;
	reg already_appended_one_8;
	reg already_appended_one_9;

	reg [k_length - 1:0] k_1;
	reg [k_length - 1:0] k_2;
	reg [k_length - 1:0] k_3;
	reg [k_length - 1:0] k_4;
	reg [k_length - 1:0] k_5;
	reg [k_length - 1:0] k_6;
	reg [k_length - 1:0] k_7;
	reg [k_length - 1:0] k_8;

	reg stop_k_encoding_1;
	reg stop_k_encoding_2;
	reg stop_k_encoding_3;
	reg stop_k_encoding_4;
	reg stop_k_encoding_5;
	reg stop_k_encoding_6;
	reg stop_k_encoding_7;
	reg stop_k_encoding_8;
	reg stop_k_encoding_9;

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	assign MErrval_RI_subtract = MErrval_RI - 1;

	always @ (k or MErrval_RI or unary or MErrval_RI_subtract) begin

		if (unary < ((limit - J -1) - qbpp - 1)) begin
				if (k > 0) begin
					encoded_pixel[0] = MErrval_RI[0];
					stop_k_encoding_1 = 0;
					k_1 = k - 1;
					already_appended_one_1 = 0;
				end
				else begin
					encoded_pixel[0] = 1;
					stop_k_encoding_1 = 1;
					k_1 = k;
					already_appended_one_1 = 1;
				end
				

				if (k_1 > 0 && !stop_k_encoding_1) begin
					encoded_pixel[1] = MErrval_RI[1];
					stop_k_encoding_2 = 0;
					k_2 = k_1 - 1;
					already_appended_one_2 = 0;
				end
				else begin
					if(!already_appended_one_1) begin
						encoded_pixel[1] = 1;
					end
					else begin
						encoded_pixel[1] = 0;
					end
					already_appended_one_2 = 1;
					stop_k_encoding_2 = 1;
					k_2 = k_1;
				end

				if (k_2 > 0 && !stop_k_encoding_2) begin
					encoded_pixel[2] = MErrval_RI[2];
					stop_k_encoding_3 = 0;
					k_3 = k_2 - 1;
					already_appended_one_3 = 0;
				end
				else begin
					if(!already_appended_one_2) begin
						encoded_pixel[2] = 1;
					end
					else begin
						encoded_pixel[2] = 0;
					end
					already_appended_one_3 = 1;
					stop_k_encoding_3 = 1;
					k_3 = k_2;
				end

				if (k_3 > 0 && !stop_k_encoding_3) begin
					encoded_pixel[3] = MErrval_RI[3];
					stop_k_encoding_4 = 0;
					k_4 = k_3 - 1;
					already_appended_one_4 = 0;
				end
				else begin
					if(!already_appended_one_3) begin
						encoded_pixel[3] = 1;
					end
					else begin
						encoded_pixel[3] = 0;
					end
					already_appended_one_4 = 1;
					stop_k_encoding_4 = 1;
					k_4 = k_3;
				end

				if (k_4 > 0 && !stop_k_encoding_4) begin
					encoded_pixel[4] = MErrval_RI[4];
					stop_k_encoding_5 = 0;
					already_appended_one_6 = 0;
					k_5 = k_4 - 1;
				end
				else begin
					if(!already_appended_one_4) begin
						encoded_pixel[4] = 1;
					end
					else begin
						encoded_pixel[4] = 0;
					end
					already_appended_one_5 = 1;
					stop_k_encoding_5 = 1;
					k_5 = k_4;
				end

				if (k_5 > 0 && !stop_k_encoding_5) begin
					encoded_pixel[5] = MErrval_RI[5];
					stop_k_encoding_6 = 0;
					k_6 = k_5 - 1;
					already_appended_one_6 = 0;
				end
				else begin
					if(!already_appended_one_5) begin
						encoded_pixel[5] = 1;
					end
					else begin
						encoded_pixel[5] = 0;
					end
					already_appended_one_6 = 1;
					stop_k_encoding_6 = 1;
					k_6 = k_5;
				end

				if (k_6 > 0 && !stop_k_encoding_6) begin
					encoded_pixel[6] = MErrval_RI[6];
					stop_k_encoding_7 = 0;
					k_7 = k_6 - 1;
					already_appended_one_7 = 0;
				end
				else begin
					if(!already_appended_one_6) begin
						encoded_pixel[6] = 1;
					end
					else begin
						encoded_pixel[6] = 0;
					end
					already_appended_one_7 = 1;
					stop_k_encoding_7 = 1;
					k_7 = k_6;
				end

				if (k_7 > 0 && !stop_k_encoding_7) begin
					encoded_pixel[7] = MErrval_RI[7];
					stop_k_encoding_8 = 0;
					k_8 = k_7 - 1;
					already_appended_one_8 = 0;
				end
				else begin
					if(!already_appended_one_7) begin
						encoded_pixel[7] = 1;
					end
					else begin
						encoded_pixel[7] = 0;
					end
					already_appended_one_8 = 1;
					stop_k_encoding_8 = 1;
					k_8 = k_7;
				end

				if (k_8 > 0 && !stop_k_encoding_8) begin
					encoded_pixel[8] = MErrval_RI[8];
					already_appended_one_9 = 0;
				end
				else begin
					if(!already_appended_one_8) begin
						encoded_pixel[8] = 1;
					end
					else begin
						encoded_pixel[8] = 0;
					end
					already_appended_one_9 = 1;
				end

				if(!already_appended_one_9) begin
					encoded_pixel[9] = 1;
				end
				else begin
					encoded_pixel[9] = 0;
				end

				encoded_pixel [encodedpixel_width - 1: 10] = 0;
				encoded_length = unary + k + 1;
				remainder_value = 0;
				limit_overflow = 0;
		end
		else begin
			limit_overflow = 1;
			encoded_pixel = 0;
			remainder_value = {1'b1, MErrval_RI_subtract[mapped_error_value_length - 2:0]};
			encoded_length = 22 - J;
		end
	end
endmodule
