`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
`include "Encode_Regular_Mode.v"
`include "Encode_RI_Mode.v"
`include "Encode_Run_Mode.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Golomb encoding module. Based on the Golomb parameter k and mapped error value the residual is Golomb encoded based on a unary/remainder 1 append mode. Limited-length Golomb
		     codes based on the mode are ensured for a max width or 23. If the max width is met then we will use the limit_overflow variable to suggest this to the subsequent stages FSM.
		     Unary is determined via a shift right mechanism. Unary size determines if limit overflow is made. The values are appened to encoded_pixel via big endian.
		     Shifter will be realized via a barrel shifter. In the case of run mode we will constantly append 1's when a hit is made. 
		     The hit is signified via a run length parameter determined in RunCoder module. This hit will be send via a encoded length parameter to the subsequent stages FSM to indicate
		     that a 1 needs to be parallel loaded out.
	
	Limit overflow is for the conditional check, if the conditional check is not met then we need to encode limit - qbpp -1 0's followed by a 1 and the 8 bits of mapped error value -1.
	Limit overflow is fed to the next stage FSM which shifts the data onto the bitstream.
	If mode == 3 then we need to check if the run count equaled run count compare on the last run count via the hit index. We will also need to append a 1 on the bitstream if run_count > 0.
======================================================================================================================================================================================================
*/

module RiceEncoding #(parameter modresidual_length = `modresidual_length, k_length = `k_length, mode_length = `mode_length, J_length = `J_length, unary_length = `unary_length, mapped_error_value_length = `mapped_error_value_length,
				  remaindervalue_length = `remaindervalue_length, encodedpixel_width = `encodedpixel_width, encodedlength_width = `encodedlength_width, N_Nn_Compare_length = `N_Nn_Compare_length, runcount_length = `runcount_length)
		       (input [modresidual_length - 1:0] errValue, input B_N_Compare, input [k_length - 1:0] k, input [N_Nn_Compare_length - 1:0] N_Nn_Compare, 
			input [mode_length - 1:0] mode, input RIType, input [J_length - 1:0] J, input [J_length - 1:0] J_Comp, input hit, input do_run_encoding, input [runcount_length - 1:0] run_length,
		        output reg [unary_length - 1:0] unary, output reg [remaindervalue_length - 1:0] remainder_value, output reg [encodedpixel_width - 1:0] encoded_pixel, 
		        output reg [encodedlength_width - 1:0] encoded_length, output reg limit_overflow, input [J_length - 1:0] J_Recurring_Mode_Two, input clk, input reset);


/* 
======================================================================================================================================================================================================
	GENERALIZED PARAMETER DECLARATIONS
======================================================================================================================================================================================================
*/
	localparam [5:0] limit = 6'd32;
	localparam [3:0] qbpp = 4'd8;


	integer i, j;

/*
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire [encodedpixel_width - 1:0] encoded_pixel_run_mode;
	wire [encodedpixel_width - 1:0] encoded_pixel_regular_mode;
	wire [encodedpixel_width - 1:0] encoded_pixel_RI_mode;

	wire [encodedlength_width - 1:0] encoded_length_run_mode;
	wire [encodedlength_width - 1:0] encoded_length_regular_mode;
	wire [encodedlength_width - 1:0] encoded_length_RI_mode;

	wire [remaindervalue_length - 1:0] remainder_value_RI_mode;
	wire [remaindervalue_length - 1:0] remainder_value_regular_mode;

	wire [unary_length - 1:0] unary_RI_mode;
	wire [unary_length - 1:0] unary_regular_mode;

	wire limit_overflow_RI_mode;
	wire limit_overflow_regular_mode;

	wire [mode_length - 1:0] previous_mode;

	reg run_length_added;

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	Encode_Run_Mode Encode_Run (.J(J), .run_length(run_length), .encoded_pixel(encoded_pixel_run_mode),
			 		  .hit(hit), .do_run_encoding(do_run_encoding), .encoded_length(encoded_length_run_mode));
	Encode_RI_Mode Encoded_RI_Mode (.k(k), .errValue(errValue), .N_Nn_Compare(N_Nn_Compare), .encoded_pixel_RI(encoded_pixel_RI_mode), .RIType(RIType),
					.encoded_length_RI(encoded_length_RI_mode), .unary_RI(unary_RI_mode), .limit_overflow_RI(limit_overflow_RI_mode), 
					.remainder_value_RI(remainder_value_RI_mode), .do_run_encoding(do_run_encoding), .J(J), .J_Comp(J_Comp), .previous_mode(previous_mode),
					.J_Recurring_Mode_Two(J_Recurring_Mode_Two));
	Encode_Regular_Mode Encode_Regular_Mode (.errValue(errValue), .B_N_Compare(B_N_Compare), .k(k), .unary(unary_regular_mode), .remainder_value_regular(remainder_value_regular_mode), 
					      .encoded_pixel_regular(encoded_pixel_regular_mode), .encoded_length_regular(encoded_length_regular_mode), 
					      .limit_overflow_regular(limit_overflow_regular_mode));

	defparam Previous_Mode.size = mode_length;
	Register Previous_Mode (.dataIn(mode), .dataOut(previous_mode), .enable(1'b1), .clk(clk), .reset(reset));

	always @ (*) begin
		run_length_added = 0;

		//Encoding for regular mode
		if (mode == 0) begin
			encoded_pixel = encoded_pixel_regular_mode;
			limit_overflow = limit_overflow_regular_mode;
			remainder_value = remainder_value_regular_mode;
			encoded_length = encoded_length_regular_mode;
			unary = unary_regular_mode;
		end

		//Run Interruption Coding
		else if (mode == 2) begin
			encoded_pixel = encoded_pixel_RI_mode;
			limit_overflow = limit_overflow_RI_mode;
			remainder_value = remainder_value_RI_mode;
			encoded_length = encoded_length_RI_mode;
			unary = unary_RI_mode;
		end
	
		//Run Mode Coding, do_run_encoding == 1 means that the next mode is 2 if current mode is 1, we need to finish the run_length_remainder coding
		else if (mode == 1) begin
			encoded_pixel = encoded_pixel_run_mode;
			limit_overflow = 0;
			remainder_value = 0;
			encoded_length = encoded_length_run_mode;
			unary = 0;
		end
		//Run Interruption Coding created by EOL (mode == 3)
		else begin
			limit_overflow = 0;
			unary = 0;
			remainder_value = 0;
			if(run_length > 0) begin
				encoded_pixel[0] = 1;
				run_length_added = 1;
			end
			else begin
				run_length_added = 0;
			end

			if(hit & run_length_added) begin
				encoded_pixel[1] = 1;
				encoded_length = 2;
			end
			else if (hit & !run_length_added) begin
				encoded_length = 1;
				encoded_pixel[0] = 1;
				encoded_pixel[1] = 0;
			end
			else if (run_length_added & !hit) begin
				encoded_pixel[1] = 0;
				encoded_length = 1;
			end
			else begin
				encoded_length = 0;
				encoded_pixel[1] = 0;
				encoded_pixel[0] = 0;
			end
			encoded_pixel[encodedpixel_width - 1: 2] = 0;
		end
	end


endmodule