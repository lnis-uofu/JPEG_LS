`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
`include "BarrelShifter.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 5/1/2020
	DESCRIPTION:  Top level module for the bit packing of limit overflow encoding. Depending on internal parameters the output of one of the internal modules is assigned to the top level
		      final encoded output. An internal barrel shifter is employed due to the number of zeros encoded by the run interruption LO encoding being dependent on the current value
		      of J[Run Index].
======================================================================================================================================================================================================
*/

module LimitOverflowEncoding #(parameter encodedpixel_width = `encodedpixel_width, encodedlength_width = `encodedlength_width, dataOut_length = `dataOut_length, remaindervalue_length = `remaindervalue_length,
					 J_length = `J_length, Shift_Width = `Shift_Width, Shift_Data_Length = `Shift_Data_Length, mode_length = `mode_length)
			      (input [7:0] previous_encoded_data, input [encodedpixel_width - 1:0] encoded_pixel, input [3:0] previous_byteoverflow_encoded_data_length, input [encodedlength_width - 1:0] encoded_length,
			       input [remaindervalue_length - 1:0] remainder_value, input [J_length - 1:0] J, input [mode_length - 1:0] mode, output reg [encodedlength_width - 1:0] final_encoded_length_limit,
			       output reg [dataOut_length - 1:0] final_encoded_pixel, output reg [7:0] current_overflow_data, output reg [3:0] current_byteoverflow_data_length);

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire [Shift_Width - 1:0] Shift_Amount;
	wire [Shift_Width - 1:0] EOR_Limit;

	wire [Shift_Data_Length - 1:0] PreShiftData;
	wire [Shift_Data_Length - 1:0] PostShiftData;
	wire [dataOut_length - 1:0] Previous_Data;

	wire [encodedlength_width - 1:0] final_encoded_data_eor_limit_length;
	wire [dataOut_length - 1:0] final_encoded_data_eor_limit;

	wire [encodedlength_width - 1:0] encoded_data_eor_limit_length;
	wire [dataOut_length - 1:0] encoded_data_eor_limit;

	wire [3:0] current_byteoverflow_data_length_eor_limit;
	wire [7:0] current_overflow_data_eor_limit;

	wire [3:0] current_byteoverflow_data_length_limit;
	wire [7:0] current_overflow_data_limit;
	wire [dataOut_length - 1:0] final_encoded_pixel_limit;

/* 
======================================================================================================================================================================================================
	MODULE INSTANTIATION
======================================================================================================================================================================================================
*/

		/* 
			Barrel Shifter will be used here. 

		---------------------------------------------------------------------------------------------------------------------------------------

			For mode == 0 the maximum shift will be 7 because if there was 7 bit of previous byte overflow we will need
			to shift remainder_length by 7 to account for the 7 bits of overflow being appended to the LSBs

		---------------------------------------------------------------------------------------------------------------------------------------

			For mode == 2 the design is slightly more intracite because the unary coding of 0's is dependent on J value. 

			If eor_limit + previous_byteoverflow_encoded_data_length > 23 then shift right, max shift is 7 with 
			previous_byteoverflow_encoded_data_length == 7 and eor_limit == 23.

			If eor_limit + previous_byteoverflow_encoded_data_length == 23 then no shift

			If eor limit + previous_byteoverflow_encoded_data_length < 23 then shift left, max shift is 
			eor limit lower bound == 7 and previous_byteoverflow_encoded_data_length == 0 so shift would be
			32 - 7 - 9 = 16

		---------------------------------------------------------------------------------------------------------------------------------------
		*/

	BarrelShifter BSH (.PreShiftData(PreShiftData), .ShiftAmount(Shift_Amount), .PostShiftData(PostShiftData));

	Encode_Limit EL (.previous_byteoverflow_encoded_data_length(previous_byteoverflow_encoded_data_length), .remainder_value(remainder_value),
			 .previous_encoded_data(previous_encoded_data), .final_encoded_pixel(final_encoded_pixel_limit), .current_overflow_data(current_overflow_data_limit),
			 .current_byteoverflow_data_length(current_byteoverflow_data_length_limit), .encoded_pixel(encoded_pixel));

	Encode_EOR_Limit EORL  (.encoded_data_eor_limit(encoded_data_eor_limit), .encoded_data_eor_limit_length(encoded_data_eor_limit_length), .final_encoded_data_eor_limit(final_encoded_data_eor_limit), 
				.final_encoded_data_eor_limit_length(final_encoded_data_eor_limit_length), .current_byteoverflow_data(current_overflow_data_eor_limit),
				.current_byteoverflow_data_length(current_byteoverflow_data_length_eor_limit));

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/
	
	//Number of 0's to be appended 23 - (J + 1)
	assign EOR_Limit = encoded_length;
	//determines how many units we need to shift remainder_value over, highest number of shift is from 9 to 41 or bitsll(.., 32)
	assign Shift_Amount = 55 - (previous_byteoverflow_encoded_data_length + EOR_Limit);
	//previous data length + number of 0's + 1 binary 1 + 8 bits of MErrval - 1
	assign encoded_data_eor_limit_length = previous_byteoverflow_encoded_data_length + EOR_Limit + 9;

	assign PreShiftData = {48'b0, remainder_value};

	assign Previous_Data = {previous_encoded_data, 56'b0};

	assign encoded_data_eor_limit = Previous_Data | {7'b0, PostShiftData};


	always @ (previous_encoded_data or encoded_pixel or previous_byteoverflow_encoded_data_length or remainder_value or final_encoded_pixel_limit or 
		  mode or final_encoded_data_eor_limit_length or current_byteoverflow_data_length_eor_limit or current_overflow_data_eor_limit or
		  current_overflow_data_limit or current_byteoverflow_data_length_limit) begin
		if (mode == 0) begin
			final_encoded_pixel = final_encoded_pixel_limit;
			current_overflow_data = current_overflow_data_limit;
			current_byteoverflow_data_length = current_byteoverflow_data_length_limit;
			final_encoded_length_limit = 32;
		end
		else if (mode == 2) begin //used to encode over limit of mode == 2
			final_encoded_pixel = final_encoded_data_eor_limit;
			current_overflow_data = current_overflow_data_eor_limit;
			current_byteoverflow_data_length = current_byteoverflow_data_length_eor_limit;
			final_encoded_length_limit = final_encoded_data_eor_limit_length;
		end
	end
endmodule