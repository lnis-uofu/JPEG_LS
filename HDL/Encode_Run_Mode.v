`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
`include "Encode_Pixel_With_Hit.v"
`include "Encode_Pixel_Without_Hit.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Top level model for run encoding. Will encode the run mode according to the ITU T.87. The module will look to see if the current run mode encoutered a hit (needs to encode
		     a binary '1', and will see if it needs to encode a '0' and the J[Run Index] bits of the run count variable depending on if the next mode is a run interruption mode.
======================================================================================================================================================================================================
*/

module Encode_Run_Mode #(parameter encodedpixel_width = `encodedpixel_width, J_length = `J_length, runcount_length = `runcount_length, encodedlength_width = `encodedlength_width)
			(input [J_length - 1:0] J, input [runcount_length - 1:0] run_length, output reg [encodedpixel_width - 1:0] encoded_pixel,
			 input hit, input do_run_encoding, output reg [encodedlength_width - 1:0] encoded_length);

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire [encodedpixel_width - 1:0] encode_pixel_with_hit;
	wire [encodedpixel_width - 1:0] encode_pixel_without_hit;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/

	reg [encodedpixel_width - 1:0] encode_pixel_hit;

/* 
======================================================================================================================================================================================================
	MODULE INSTANTIATION
======================================================================================================================================================================================================
*/

	Encode_Pixel_With_Hit RunEncodeAndHit (.J(J), .run_length(run_length), .encoded_pixel(encode_pixel_with_hit));
	Encode_Pixel_Without_Hit Enocde_Without_Hit (.J(J), .run_length(run_length), .encoded_pixel(encode_pixel_without_hit));

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/


	always @ (J or do_run_encoding or hit or run_length or encode_pixel_with_hit or encode_pixel_without_hit) begin

			encode_pixel_hit[0] = 1;
			encode_pixel_hit[encodedpixel_width - 1:1] = 0;

			if(do_run_encoding & !hit) begin
	
				encoded_pixel = encode_pixel_without_hit;
				encoded_length = J + 1;

			end
			else if (do_run_encoding & hit) begin

				encoded_pixel = encode_pixel_with_hit;
				encoded_length = J + 2;

			end
			else if (!do_run_encoding & hit) begin
				encoded_pixel = encode_pixel_hit;
				encoded_length = 1;
			end
			else begin
				encoded_pixel = 0;
				encoded_length = 0;
			end
	end
endmodule

