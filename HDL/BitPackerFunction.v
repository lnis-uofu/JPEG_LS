`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 7/20/2020
	DESCRIPTION: Function who implements the byte-size compression of the output values. The funciton will take into account and overflow data from the previous encoding cycles that 
		     does not meet a modulo-8 size output, and will append it to the MSBs of the current encoded pixel. Then the current encoded pixel will be appened to these bits.
		     The function will then proceed to follow a set of parallel/priority encoded set of conditions which map this appened data to the final output. Depending
		     on the size of the output there will be a flag set to indiciate data is ready to be sampled. Any overflow data will be assigned to the correct values
		     and outputted to be stored in an external register.
======================================================================================================================================================================================================
*/

module BitPackerFunciton #(parameter encodedpixel_width = `encodedpixel_width, encodedlength_width = `encodedlength_width, dataOut_length = `dataOut_length)
			 (input [encodedpixel_width - 1:0] encoded_pixel, input [encodedlength_width - 1:0] encoded_length, input [7:0] previous_encoded_data, input [3:0] previous_byteoverflow_encoded_data_length,
			  output reg [dataOut_length - 1:0] final_encoded_pixel, output reg [encodedlength_width - 1:0] final_encoded_length, output reg [7:0] current_overflow_data, output reg [3:0] current_byteoverflow_data_length,
			  output reg dataReady);

/* 
======================================================================================================================================================================================================
	GENERALIZED PARAMETER DECLARATIONS
======================================================================================================================================================================================================
*/
	
	localparam internalDataOut_length = 56;


/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire [7:0] overflow_byte_one;
	wire [7:0] overflow_byte_two;
	wire [7:0] overflow_byte_three;
	wire [7:0] overflow_byte_four;
	wire [7:0] overflow_byte_five;
	wire [7:0] overflow_byte_six;
	wire [7:0] overflow_byte_seven;
	wire [7:0] overflow_byte_eight;

	wire [encodedlength_width - 1:0] total_data_length;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/

	reg zero_appended_1;
	reg [1:0] zero_appended_2;
	reg [2:0] zero_appended_3;
	reg [2:0] zero_appended_4;
	reg [3:0] zero_appended_5;
	reg [3:0] zero_appended_6;


	reg length_append_1;
	reg length_append_2;
	reg length_append_3;
	reg length_append_4;
	reg length_append_5;
	reg length_append_6;
	reg length_append_7;
	
	reg [internalDataOut_length - 1:0] data_output;
	reg [encodedlength_width - 1:0] dataOutLength;

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	assign total_data_length = encoded_length + previous_byteoverflow_encoded_data_length;

	assign overflow_byte_one = final_encoded_pixel[dataOut_length - 1: dataOut_length - 8];
	assign overflow_byte_two = final_encoded_pixel[dataOut_length - 9: dataOut_length - 16];
	assign overflow_byte_three = final_encoded_pixel[dataOut_length - 17: dataOut_length - 24];
	assign overflow_byte_four = final_encoded_pixel[dataOut_length - 25: dataOut_length - 32];
	assign overflow_byte_five = final_encoded_pixel[dataOut_length - 33: dataOut_length - 40];
	assign overflow_byte_six = final_encoded_pixel[dataOut_length - 41: dataOut_length - 48];
	assign overflow_byte_seven = final_encoded_pixel[dataOut_length - 49: dataOut_length - 56];
	assign overflow_byte_eight = final_encoded_pixel[dataOut_length - 57: dataOut_length - 64];

	always @ (encoded_pixel or encoded_length or previous_byteoverflow_encoded_data_length or previous_encoded_data 
		  or overflow_byte_one or overflow_byte_two or overflow_byte_three or overflow_byte_four or dataOutLength
		  or overflow_byte_five or overflow_byte_six) begin


		if (previous_byteoverflow_encoded_data_length == 7) begin
			data_output = {previous_encoded_data[7:1],encoded_pixel, 1'b0};
		end
		else if (previous_byteoverflow_encoded_data_length == 6) begin
			data_output = {previous_encoded_data[7:2],encoded_pixel, 2'b0};
		end
		else if (previous_byteoverflow_encoded_data_length == 5) begin
			data_output = {previous_encoded_data[7:3],encoded_pixel, 3'b0};
		end
		else if (previous_byteoverflow_encoded_data_length == 4) begin
			data_output = {previous_encoded_data[7:4],encoded_pixel, 4'b0};
		end
		else if (previous_byteoverflow_encoded_data_length == 3) begin
			data_output = {previous_encoded_data[7:5],encoded_pixel, 5'b0};
		end
		else if (previous_byteoverflow_encoded_data_length == 2) begin
			data_output = {previous_encoded_data[7:6],encoded_pixel, 6'b0};
		end
		else if (previous_byteoverflow_encoded_data_length == 1) begin
			data_output = {previous_encoded_data[7],encoded_pixel, 7'b0};
		end
		else begin
			data_output = {encoded_pixel, 8'b0};
		end

/* 
======================================================================================================================================================================================================
	FIRST BYTE
======================================================================================================================================================================================================
*/
		final_encoded_pixel[63:56] = data_output[55:48];

/* 
======================================================================================================================================================================================================
	SECOND BYTE
======================================================================================================================================================================================================
*/
		//final_encoded_pixel[31:24] = data_output[31:24];
		if(final_encoded_pixel[63:56] == 8'b11111111) begin
			final_encoded_pixel[55:48] = {1'b0,data_output[47:41]};
			zero_appended_1 = 1;
			length_append_1 = 1;
		end
		else begin
			final_encoded_pixel[55:48] = data_output[47:40];
			zero_appended_1 = 0;
			length_append_1 = 0;
		end

/* 
======================================================================================================================================================================================================
	THIRD BYTE
======================================================================================================================================================================================================
*/

	/*
		if(final_encoded_pixel[31:24] == 8'b11111111) begin
			final_encoded_pixel[23:16] = {1'b0,data_output[23:17]};
			zero_appended_1 = 1;
		end
		else begin
			final_encoded_pixel[23:16] = data_output[23:16];
			zero_appended_1 = 0;
		end
	*/

		if(zero_appended_1) begin
			final_encoded_pixel[47:40] = data_output[40:33];
			zero_appended_2 = 2;
			length_append_2 = 0;
		end
		else if (final_encoded_pixel[55:48] == 8'b11111111 && !zero_appended_1) begin
			final_encoded_pixel[47:40] = {1'b0, data_output[39:33]};
			zero_appended_2 = 1;
			length_append_2 = 1;
		end
		else begin
			final_encoded_pixel[47:40] = data_output[39:32];
			zero_appended_2 = 0;
			length_append_2 = 0;
		end
/* 
======================================================================================================================================================================================================
	FOURTH BYTE
======================================================================================================================================================================================================
*/

		/*if(final_encoded_pixel[39:32] != 8'b11111111 && zero_appended_2 == 2) begin
			final_encoded_pixel[31:24] = data_output[32:25];
			zero_appended_3 = 4;
			length_append_3 = 0;
		end*/
		if (final_encoded_pixel[47:40] == 8'b11111111 && zero_appended_2 == 2) begin
			final_encoded_pixel[39:32] = {1'b0, data_output[32:26]};
			zero_appended_3 = 3;
			length_append_3 = 1;
		end
		else if (final_encoded_pixel[47:40] == 8'b11111111 && zero_appended_2 == 0) begin
			final_encoded_pixel[39:32] = {1'b0, data_output[31:25]};
			zero_appended_3 = 2;
			length_append_3 = 1;
		end
		else if(final_encoded_pixel[47:40] != 8'b11111111 && zero_appended_2 == 0) begin
			final_encoded_pixel[39:32] = data_output[31:24];
			zero_appended_3 = 1;
			length_append_3 = 0;
		end
		else begin //covers zero_appended_2 == 1
			final_encoded_pixel[39:32] = data_output[32:25];
			zero_appended_3 = 0;
			length_append_3 = 0;
		end
/* 
======================================================================================================================================================================================================
	FIFTH BYTE
======================================================================================================================================================================================================
*/

		/*if(final_encoded_pixel[31:24] == 8'b11111111 && zero_appended_3 == 4) begin
			final_encoded_pixel[23:16] = {1'b0, data_output[24:18]};
			zero_appended_4 = 7;
			length_append_4 = 1;
		end
		else if(final_encoded_pixel[31:24] != 8'b11111111 && zero_appended_3 == 4) begin
			final_encoded_pixel[23:16] = data_output[24:17];
			zero_appended_4 = 6;
			length_append_4 = 0;
		end*/
		if (zero_appended_3 == 3) begin
			final_encoded_pixel[31:24] = data_output[25:18];
			zero_appended_4 = 4;
			length_append_4 = 0;
		end
		/*else if (zero_appended_3 == 2) begin
			final_encoded_pixel[23:16] = data_output[24:17];
			zero_appended_4 = 4;
			length_append_4 = 0;
		end*/
		else if(final_encoded_pixel[39:32] == 8'b11111111 && zero_appended_3 == 1) begin
			final_encoded_pixel[31:24] = {1'b0, data_output[23:17]};
			zero_appended_4 = 3;
			length_append_4 = 1;
		end
		else if(final_encoded_pixel[39:32] != 8'b11111111 && zero_appended_3 == 1) begin
			final_encoded_pixel[31:24] = data_output[23:16];
			zero_appended_4 = 2;
			length_append_4 = 0;
		end
		else if(final_encoded_pixel[39:32] == 8'b11111111 && zero_appended_3 == 0) begin
			final_encoded_pixel[31:24] = {1'b0, data_output[24:18]};
			zero_appended_4 = 1;
			length_append_4 = 1;
		end
		else begin //covers zero_appended_3 == 0 and 2
			final_encoded_pixel[31:24] = data_output[24:17];
			zero_appended_4 = 0;
			length_append_4 = 0;
		end
/* 
======================================================================================================================================================================================================
	SIXTH BYTE
======================================================================================================================================================================================================
*/

		/*if(final_encoded_pixel[23:16] == 8'b11111111 && zero_appended_4 == 6) begin
			final_encoded_pixel[15:8] = {1'b0, data_output[16:10]};
			length_append_5 = 1;
			zero_appended_5 = 12;
		end
		else if(final_encoded_pixel[23:16] != 8'b11111111 && zero_appended_4 == 6) begin
			final_encoded_pixel[15:8] = data_output[16:9];
			length_append_5 = 0;
			zero_appended_5 = 11;
		end
		else if (zero_appended_4 == 7) begin
			final_encoded_pixel[15:8] = data_output[17:10];
			length_append_5 = 0;
			zero_appended_5 = 10;
		end
		else if (final_encoded_pixel[23:16] == 8'b11111111 && zero_appended_4 == 5) begin
			final_encoded_pixel[15:8] = {1'b0, data_output[17:11]};
			length_append_5 = 0;
			zero_appended_5 = 9;
		end
		else if (final_encoded_pixel[23:16] != 8'b11111111 && zero_appended_4 == 5) begin
			final_encoded_pixel[15:8] = data_output[17:10];
			length_append_5 = 0;
			zero_appended_5 = 8;
		end*/
		if (final_encoded_pixel[31:24] == 8'b11111111 && zero_appended_4 == 4) begin
			final_encoded_pixel[23:16] = {1'b0, data_output[17:11]};
			length_append_5 = 1;
			zero_appended_5 = 6;
		end
		else if (final_encoded_pixel[31:24] != 8'b11111111 && zero_appended_4 == 4) begin
			final_encoded_pixel[23:16] = data_output[17:10];
			length_append_5 = 0;
			zero_appended_5 = 5;
		end
		/*else if (zero_appended_4 == 3) begin
			final_encoded_pixel[15:8] = data_output[16:9];
			length_append_5 = 0;
			zero_appended_5 = 5;
		end*/
		else if(final_encoded_pixel[31:24] == 8'b11111111 && zero_appended_4 == 2) begin
			final_encoded_pixel[23:16] = {1'b0, data_output[15:9]};
			length_append_5 = 1;
			zero_appended_5 = 4;
		end
		else if(final_encoded_pixel[31:24] != 8'b11111111 && zero_appended_4 == 2) begin
			final_encoded_pixel[23:16] = data_output[15:8];
			length_append_5 = 0;
			zero_appended_5 = 3;
		end
		else if (zero_appended_4 == 1) begin
			final_encoded_pixel[23:16] = data_output[17:9];
			length_append_5 = 0;
			zero_appended_5 = 2;
		end
		else if(final_encoded_pixel[31:24] == 8'b11111111 && zero_appended_4 == 0) begin
			final_encoded_pixel[23:16] = {1'b0, data_output[16:10]};
			length_append_5 = 1;
			zero_appended_5 = 1;
		end
		else begin //covers zero_appended_3 == 0 and 3
			final_encoded_pixel[23:16] = data_output[16:9];
			length_append_5 = 0;
			zero_appended_5 = 0;
		end

/* 
======================================================================================================================================================================================================
	SEVENTH BYTE
======================================================================================================================================================================================================
*/
		/*if (zero_appended_5 == 12) begin
			final_encoded_pixel[7:0] = data_output[9:2];
			length_append_6 = 0;
		end
		else if(final_encoded_pixel[15:8] == 8'b11111111 && zero_appended_5 == 11) begin
			final_encoded_pixel[7:0] = {1'b0, data_output[8:2]};
			length_append_6 = 1;
		end
		else if(final_encoded_pixel[15:8] != 8'b11111111 && zero_appended_5 == 11) begin
			final_encoded_pixel[7:0] = data_output[8:1];
			length_append_6 = 0;
		end
		else if(final_encoded_pixel[15:8] == 8'b11111111 && zero_appended_5 == 10) begin
			final_encoded_pixel[7:0] = {1'b0, data_output[9:3]};
			length_append_6 = 1;
		end
		else if(final_encoded_pixel[15:8] != 8'b11111111 && zero_appended_5 == 10) begin
			final_encoded_pixel[7:0] = data_output[9:2];
			length_append_6 = 0;
		end
		else if (zero_appended_5 == 9) begin
			final_encoded_pixel[7:0] = data_output[10:3];
			length_append_6 = 0;
		end
		else if(final_encoded_pixel[15:8] == 8'b11111111 && zero_appended_5 == 8) begin
			final_encoded_pixel[7:0] = {1'b0, data_output[9:3]};
			length_append_6 = 1;
		end
		else if(final_encoded_pixel[15:8] != 8'b11111111 && zero_appended_5 == 8) begin
			final_encoded_pixel[7:0] = data_output[9:2];
			length_append_6 = 0;
		end*/
		if (zero_appended_5 == 6) begin
			final_encoded_pixel[7:0] = data_output[10:3];
			length_append_6 = 0;
			zero_appended_6 = 7;
		end
		else if(final_encoded_pixel[23:16] == 8'b11111111 && zero_appended_5 == 5) begin
			final_encoded_pixel[7:0] = {1'b0, data_output[9:3]};
			length_append_6 = 1;
			zero_appended_6 = 6;
		end
		else if((final_encoded_pixel[23:16] != 8'b11111111 && zero_appended_5 == 5) || zero_appended_5 == 1) begin
			final_encoded_pixel[7:0] = data_output[9:2];
			length_append_6 = 0;
			zero_appended_6 = 5;
		end
		/*else if(final_encoded_pixel[15:8] == 8'b11111111 && zero_appended_5 == 5) begin
			final_encoded_pixel[7:0] = {1'b0, data_output[8:2]};
			length_append_6 = 1;
		end
		else if(final_encoded_pixel[15:8] != 8'b11111111 && zero_appended_5 == 5) begin
			final_encoded_pixel[7:0] = data_output[8:1];
			length_append_6 = 0;
		end
		else if (zero_appended_5 == 4) begin
			final_encoded_pixel[7:0] = data_output[8:1];
			length_append_6 = 0;
			zero_appended_6 = 6;
		end*/
		else if(final_encoded_pixel[23:16] == 8'b11111111 && zero_appended_5 == 3) begin
			final_encoded_pixel[15:8] = {1'b0, data_output[7:1]};
			length_append_6 = 1;
			zero_appended_6 = 4;
		end
		else if(final_encoded_pixel[23:16] != 8'b11111111 && zero_appended_5 == 3) begin
			final_encoded_pixel[15:8] = data_output[7:0];
			length_append_6 = 0;
			zero_appended_6 = 3;
		end
		else if(final_encoded_pixel[23:16] == 8'b11111111 && (zero_appended_5 == 2 || zero_appended_5 == 0)) begin
			final_encoded_pixel[15:8] = {1'b0, data_output[8:2]};
			length_append_6 = 1;
			zero_appended_6 = 2;
		end
		else if((final_encoded_pixel[23:16] != 8'b11111111 && zero_appended_5 == 2) || zero_appended_5 == 4) begin
			final_encoded_pixel[15:8] = data_output[8:1];
			length_append_6 = 0;
			zero_appended_6 = 1;
		end
		/*else if (zero_appended_5 == 1) begin
			final_encoded_pixel[7:0] = data_output[9:2];
			length_append_6 = 0;
		end
		else if(final_encoded_pixel[23:16] == 8'b11111111 && zero_appended_5 == 0) begin
			final_encoded_pixel[7:0] = {1'b0, data_output[8:2]};
			length_append_6 = 1;
			zero_appended_6 = 1;
		end*/
		else begin //covers zero_appended_3 == 0
			final_encoded_pixel[15:8] = data_output[8:1];
			length_append_6 = 0;
			zero_appended_6 = 0;
		end

/* 
======================================================================================================================================================================================================
	EIGHTH BYTE
======================================================================================================================================================================================================
*/
		if (final_encoded_pixel[15:8] == 8'b11111111 && zero_appended_6 == 7) begin
			final_encoded_pixel[7:0] = {1'b0, data_output[2:0], 4'b0};
			length_append_7 = 1;
		end
		else if (final_encoded_pixel[15:8] != 8'b11111111 && zero_appended_6 == 7) begin
			final_encoded_pixel[7:0] = {data_output[2:0], 5'b0};
			length_append_7 = 0;
		end
		else if(zero_appended_6 == 6) begin
			final_encoded_pixel[7:0] = {data_output[2:0], 5'b0};
			length_append_7 = 0;
		end
		else if(final_encoded_pixel[15:8] != 8'b11111111 && zero_appended_6 == 5) begin
			final_encoded_pixel[7:0] = {data_output[1:0], 6'b0};
			length_append_7 = 0;
		end
		else if(final_encoded_pixel[15:8] == 8'b11111111 && zero_appended_6 == 5) begin
			final_encoded_pixel[7:0] = {1'b0, data_output[1:0], 5'b0};
			length_append_7 = 1;
		end
		else if (zero_appended_6 == 4) begin
			final_encoded_pixel[7:0] = {data_output[0], 7'b0};
			length_append_7 = 0;
		end
		else if(final_encoded_pixel[15:8] != 8'b11111111 && zero_appended_6 == 3) begin
			final_encoded_pixel[7:0] = 0;
			length_append_7 = 0;
		end
		else if(final_encoded_pixel[15:8] == 8'b11111111 && zero_appended_6 == 3) begin
			final_encoded_pixel[7:0] = 0;
			length_append_7 = 1;
		end
		else if (zero_appended_6 == 2) begin
			final_encoded_pixel[7:0] = {data_output[1:0], 6'b0};
			length_append_7 = 0;
		end
		else if(final_encoded_pixel[15:8] != 8'b11111111 && zero_appended_6 == 1) begin
			final_encoded_pixel[7:0] = {data_output[0], 7'b0};
			length_append_7 = 0;
		end
		else if(final_encoded_pixel[15:8] == 8'b11111111 && zero_appended_6 == 1) begin
			final_encoded_pixel[7:0] = {1'b0, data_output[0], 6'b0};
			length_append_7 = 1;
		end
		else if(final_encoded_pixel[15:8] != 8'b11111111 && zero_appended_6 == 0) begin
			final_encoded_pixel[7:0] = {data_output[0], 7'b0};
			length_append_7 = 0;
		end
		else begin
			final_encoded_pixel[7:0] = {1'b0, data_output[0], 6'b0};
			length_append_7 = 1;
		end


		
		dataOutLength = total_data_length + length_append_1 + length_append_2 + length_append_3 + length_append_4 + length_append_5 + length_append_6 + length_append_7;
		

		if (dataOutLength < 8) begin
			current_overflow_data = overflow_byte_one;
			current_byteoverflow_data_length = encoded_length + previous_byteoverflow_encoded_data_length;
			dataReady = 0;
			final_encoded_length = dataOutLength;
		end
		else if (dataOutLength == 8) begin
			current_overflow_data = 0;
			current_byteoverflow_data_length = 0;
			dataReady = 1;
			final_encoded_length = dataOutLength;
		end
		else if (dataOutLength > 8 && dataOutLength < 16) begin
			current_overflow_data = overflow_byte_two;
			current_byteoverflow_data_length = dataOutLength - 8;
			final_encoded_length = 8;
			dataReady = 1;
		end
		else if (dataOutLength == 16) begin
			current_overflow_data = 0;
			current_byteoverflow_data_length = 0;
			final_encoded_length = 16;
			dataReady = 1;
		end
		else if (dataOutLength > 16 && dataOutLength < 24) begin
			current_overflow_data = overflow_byte_three;
			current_byteoverflow_data_length = dataOutLength - 16;
			final_encoded_length = 16;
			dataReady = 1;
		end
		else if (dataOutLength == 24) begin
			current_overflow_data = 0;
			current_byteoverflow_data_length = 0;
			final_encoded_length = 24;
			dataReady = 1;
		end
		else if (dataOutLength > 24 && dataOutLength < 32) begin
			current_overflow_data = overflow_byte_four;
			current_byteoverflow_data_length = dataOutLength - 24;
			final_encoded_length = 24;
			dataReady = 1;
		end
		else if (dataOutLength == 32) begin
			current_overflow_data = 0;
			current_byteoverflow_data_length = 0;
			final_encoded_length = 32;
			dataReady = 1;
		end
		else if (dataOutLength > 32 && dataOutLength < 40) begin
			current_overflow_data = overflow_byte_five;
			current_byteoverflow_data_length = dataOutLength - 32;
			final_encoded_length = 32;
			dataReady = 1;
		end
		else if (dataOutLength == 40) begin
			current_overflow_data = 0;
			current_byteoverflow_data_length = 0;
			final_encoded_length = 40;
			dataReady = 1;
		end
		else if (dataOutLength > 40 && dataOutLength < 48) begin
			current_overflow_data = overflow_byte_six;
			current_byteoverflow_data_length = dataOutLength - 40;
			final_encoded_length = 40;
			dataReady = 1;
		end
		else if (dataOutLength == 48) begin
			current_overflow_data = 0;
			current_byteoverflow_data_length = 0;
			final_encoded_length = 48;
			dataReady = 1;
		end
		else if (dataOutLength > 48 && dataOutLength < 56) begin
			current_overflow_data = overflow_byte_seven;
			current_byteoverflow_data_length = dataOutLength - 48;
			final_encoded_length = 48;
			dataReady = 1;
		end
		else if (dataOutLength == 56) begin
			current_overflow_data = 0;
			current_byteoverflow_data_length = 0;
			final_encoded_length = 56;
			dataReady = 1;
		end
		else if (dataOutLength > 56 && dataOutLength < 64) begin
			current_overflow_data = overflow_byte_eight;
			current_byteoverflow_data_length = dataOutLength - 56;
			final_encoded_length = 56;
			dataReady = 1;
		end
		else if (dataOutLength == 64) begin
			current_overflow_data = 0;
			current_byteoverflow_data_length = 0;
			final_encoded_length = 64;
			dataReady = 1;
		end
		else begin
			current_overflow_data = 0;
			current_byteoverflow_data_length = 0;
			final_encoded_length = 0;
			dataReady = 0;
		end

	end
endmodule

	
