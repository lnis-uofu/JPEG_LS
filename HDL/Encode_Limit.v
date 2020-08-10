`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

//We will only output byte size so 32 bits is the max on this modulem it will include
// previous overflow bytes, 23 zeros, and 9 bits of MErrval, any previous overflow byres
// will cause only the upper bits of MErrval to be encoded on this cycle, rest will be stored as overflow data

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 7/25/2020
	DESCRIPTION: Encode_Limit is responsible for limit overflow encoding of regular mode coding. The module will take the input encoded data and its length. It will use
		     the length to orient it in a byte-packed size, and will output any of the remaing bits into a external register.
======================================================================================================================================================================================================
*/

module Encode_Limit #(parameter dataOut_length = `dataOut_length, remaindervalue_length = `remaindervalue_length, encodedpixel_width = `encodedpixel_width)
		     (input [3:0] previous_byteoverflow_encoded_data_length, input [remaindervalue_length - 1:0] remainder_value, input [7:0] previous_encoded_data, input [encodedpixel_width - 1:0] encoded_pixel,
		      output reg [dataOut_length - 1:0] final_encoded_pixel, output reg [7:0] current_overflow_data, output reg [3:0] current_byteoverflow_data_length);

	always @ (previous_byteoverflow_encoded_data_length or remainder_value or previous_encoded_data or encoded_pixel) begin
		if (previous_byteoverflow_encoded_data_length == 7) begin
			final_encoded_pixel = {previous_encoded_data[7:1],encoded_pixel[encodedpixel_width - 1:encodedpixel_width - 23], remainder_value[remaindervalue_length - 1: remaindervalue_length - 2], 32'b0};
			current_overflow_data = {remainder_value[remaindervalue_length - 3: 0], 1'b0};
			current_byteoverflow_data_length = 7;
		end
		else if (previous_byteoverflow_encoded_data_length == 6) begin
			final_encoded_pixel = {previous_encoded_data[7:2],encoded_pixel[encodedpixel_width - 1:encodedpixel_width - 23], remainder_value[remaindervalue_length - 1: remaindervalue_length - 3], 32'b0};
			current_overflow_data = {remainder_value[remaindervalue_length - 4: 0], 2'b0};
			current_byteoverflow_data_length = 6;
		end
		else if (previous_byteoverflow_encoded_data_length == 5) begin
			final_encoded_pixel = {previous_encoded_data[7:3],encoded_pixel[encodedpixel_width - 1:encodedpixel_width - 23], remainder_value[remaindervalue_length - 1: remaindervalue_length - 4], 32'b0};
			current_overflow_data = {remainder_value[remaindervalue_length - 5: 0], 3'b0};
			current_byteoverflow_data_length = 5;
		end
		else if (previous_byteoverflow_encoded_data_length == 4) begin
			final_encoded_pixel = {previous_encoded_data[7:4],encoded_pixel[encodedpixel_width - 1:encodedpixel_width - 23], remainder_value[remaindervalue_length - 1: remaindervalue_length - 5], 32'b0};
			current_overflow_data = {remainder_value[remaindervalue_length - 6: 0], 4'b0};
			current_byteoverflow_data_length = 4;
		end
		else if (previous_byteoverflow_encoded_data_length == 3) begin
			final_encoded_pixel = {previous_encoded_data[7:5],encoded_pixel[encodedpixel_width - 1:encodedpixel_width - 23], remainder_value[remaindervalue_length - 1: remaindervalue_length - 6], 32'b0};
			current_overflow_data = {remainder_value[remaindervalue_length - 7: 0], 5'b0};
			current_byteoverflow_data_length = 3;
		end
		else if (previous_byteoverflow_encoded_data_length == 2) begin
			final_encoded_pixel = {previous_encoded_data[7:6],encoded_pixel[encodedpixel_width - 1:encodedpixel_width - 23], remainder_value[remaindervalue_length - 1: remaindervalue_length - 7], 32'b0};
			current_overflow_data = {remainder_value[remaindervalue_length - 8: 0], 6'b0};
			current_byteoverflow_data_length = 2;
		end
		else if (previous_byteoverflow_encoded_data_length == 1) begin
			final_encoded_pixel = {previous_encoded_data[7],encoded_pixel[encodedpixel_width - 1:encodedpixel_width - 23], remainder_value[remaindervalue_length - 1: remaindervalue_length - 8], 32'b0};
			current_overflow_data = {remainder_value[0], 7'b0};
			current_byteoverflow_data_length = 1;
		end
		else begin
			final_encoded_pixel = {encoded_pixel[encodedpixel_width - 1:encodedpixel_width - 23], remainder_value, 32'b0};
			current_overflow_data = 0;
			current_byteoverflow_data_length = 0;
		end
	end
endmodule