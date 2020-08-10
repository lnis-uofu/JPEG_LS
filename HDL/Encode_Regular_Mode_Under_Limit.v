`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 7/26/2020
	DESCRIPTION: Encodes the Regular mode under limit sequence. Unary 0's will be appened to the bitstream, followed by a '1', and the k LSBs for MErrval. The sequence is encoded
		     backwards starting from the LSB of MErrval to unary.
======================================================================================================================================================================================================
*/

module Encode_Regular_Mode_Under_Limit #(parameter k_length = `k_length, mode_length = `mode_length, mapped_error_value_length = `mapped_error_value_length, 
						   remaindervalue_length = `remaindervalue_length, encodedpixel_width = `encodedpixel_width, encodedlength_width = `encodedlength_width)
					(input [mapped_error_value_length - 1:0] MErrval, input [k_length - 1:0] k, output reg [encodedpixel_width - 1:0] encoded_regular_pixel_under_limit);

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/

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

	reg already_appended_one_1;
	reg already_appended_one_2;
	reg already_appended_one_3;
	reg already_appended_one_4;
	reg already_appended_one_5;
	reg already_appended_one_6;
	reg already_appended_one_7;
	reg already_appended_one_8;
	reg already_appended_one_9;

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	always @ (MErrval or k) begin
			
				if (k > 0) begin
					encoded_regular_pixel_under_limit[0] = MErrval[0];
					stop_k_encoding_1 = 0;
					k_1 = k - 1;
					already_appended_one_1 = 0;
				end
				else begin
					encoded_regular_pixel_under_limit[0] = 1;
					stop_k_encoding_1 = 1;
					k_1 = k;
					already_appended_one_1 = 1;
				end
				

				if (k_1 > 0 && !stop_k_encoding_1) begin
					encoded_regular_pixel_under_limit[1] = MErrval[1];
					stop_k_encoding_2 = 0;
					k_2 = k_1 - 1;
					already_appended_one_2 = 0;
				end
				else begin
					if(!already_appended_one_1) begin
						encoded_regular_pixel_under_limit[1] = 1;
					end
					else begin
						encoded_regular_pixel_under_limit[1] = 0;
					end
					already_appended_one_2 = 1;
					stop_k_encoding_2 = 1;
					k_2 = k_1;
				end

				if (k_2 > 0 && !stop_k_encoding_2) begin
					encoded_regular_pixel_under_limit[2] = MErrval[2];
					stop_k_encoding_3 = 0;
					k_3 = k_2 - 1;
					already_appended_one_3 = 0;
				end
				else begin
					if(!already_appended_one_2) begin
						encoded_regular_pixel_under_limit[2] = 1;
					end
					else begin
						encoded_regular_pixel_under_limit[2] = 0;
					end
					already_appended_one_3 = 1;
					stop_k_encoding_3 = 1;
					k_3 = k_2;
				end

				if (k_3 > 0 && !stop_k_encoding_3) begin
					encoded_regular_pixel_under_limit[3] = MErrval[3];
					stop_k_encoding_4 = 0;
					k_4 = k_3 - 1;
					already_appended_one_4 = 0;
				end
				else begin
					if(!already_appended_one_3) begin
						encoded_regular_pixel_under_limit[3] = 1;
					end
					else begin
						encoded_regular_pixel_under_limit[3] = 0;
					end
					already_appended_one_4 = 1;
					stop_k_encoding_4 = 1;
					k_4 = k_3;
				end

				if (k_4 > 0 && !stop_k_encoding_4) begin
					encoded_regular_pixel_under_limit[4] = MErrval[4];
					stop_k_encoding_5 = 0;
					already_appended_one_6 = 0;
					k_5 = k_4 - 1;
				end
				else begin
					if(!already_appended_one_4) begin
						encoded_regular_pixel_under_limit[4] = 1;
					end
					else begin
						encoded_regular_pixel_under_limit[4] = 0;
					end
					already_appended_one_5 = 1;
					stop_k_encoding_5 = 1;
					k_5 = k_4;
				end

				if (k_5 > 0 && !stop_k_encoding_5) begin
					encoded_regular_pixel_under_limit[5] = MErrval[5];
					stop_k_encoding_6 = 0;
					k_6 = k_5 - 1;
					already_appended_one_6 = 0;
				end
				else begin
					if(!already_appended_one_5) begin
						encoded_regular_pixel_under_limit[5] = 1;
					end
					else begin
						encoded_regular_pixel_under_limit[5] = 0;
					end
					already_appended_one_6 = 1;
					stop_k_encoding_6 = 1;
					k_6 = k_5;
				end

				if (k_6 > 0 && !stop_k_encoding_6) begin
					encoded_regular_pixel_under_limit[6] = MErrval[6];
					stop_k_encoding_7 = 0;
					k_7 = k_6 - 1;
					already_appended_one_7 = 0;
				end
				else begin
					if(!already_appended_one_6) begin
						encoded_regular_pixel_under_limit[6] = 1;
					end
					else begin
						encoded_regular_pixel_under_limit[6] = 0;
					end
					already_appended_one_7 = 1;
					stop_k_encoding_7 = 1;
					k_7 = k_6;
				end

				if (k_7 > 0 && !stop_k_encoding_7) begin
					encoded_regular_pixel_under_limit[7] = MErrval[7];
					stop_k_encoding_8 = 0;
					k_8 = k_7 - 1;
					already_appended_one_8 = 0;
				end
				else begin
					if(!already_appended_one_7) begin
						encoded_regular_pixel_under_limit[7] = 1;
					end
					else begin
						encoded_regular_pixel_under_limit[7] = 0;
					end
					already_appended_one_8 = 1;
					stop_k_encoding_8 = 1;
					k_8 = k_7;
				end

				if (k_8 > 0 && !stop_k_encoding_8) begin
					encoded_regular_pixel_under_limit[8] = MErrval[8];
					already_appended_one_9 = 0;
				end
				else begin
					if(!already_appended_one_8) begin
						encoded_regular_pixel_under_limit[8] = 1;
					end
					else begin
						encoded_regular_pixel_under_limit[8] = 0;
					end
					already_appended_one_9 = 1;
				end

				if(!already_appended_one_9) begin
					encoded_regular_pixel_under_limit[9] = 1;
				end
				else begin
					encoded_regular_pixel_under_limit[9] = 0;
				end

				encoded_regular_pixel_under_limit [encodedpixel_width - 1: 10] = 0;
	end
endmodule