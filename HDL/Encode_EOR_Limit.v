`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 7/25/2020
	DESCRIPTION: Encode_EOR_Limit is responsible for limit overflow encoding of run interruption mode coding. The module will take the input encoded data and its length. It will use
		     the length to orient it in a byte-packed size, and will output any of the remaing bits into a external register.
======================================================================================================================================================================================================
*/

module Encode_EOR_Limit #(parameter encodedlength_width = `encodedlength_width, dataOut_length = `dataOut_length)
			 (input [dataOut_length - 1:0] encoded_data_eor_limit, input [encodedlength_width - 1:0] encoded_data_eor_limit_length, output [dataOut_length - 1:0] final_encoded_data_eor_limit,
			  output reg [encodedlength_width - 1:0] final_encoded_data_eor_limit_length, output reg [7:0] current_byteoverflow_data, output reg [3:0] current_byteoverflow_data_length);
	
	assign final_encoded_data_eor_limit = encoded_data_eor_limit;


	always @ (encoded_data_eor_limit or encoded_data_eor_limit_length) begin
		if(encoded_data_eor_limit_length == 16) begin
			final_encoded_data_eor_limit_length = encoded_data_eor_limit_length;
			current_byteoverflow_data = 0;
			current_byteoverflow_data_length = 0;
		end
		else if (encoded_data_eor_limit_length > 16 && encoded_data_eor_limit_length < 24) begin
			final_encoded_data_eor_limit_length = 16;
			current_byteoverflow_data = encoded_data_eor_limit[47:40];
			current_byteoverflow_data_length = encoded_data_eor_limit_length - 16;
		end
		else if (encoded_data_eor_limit_length == 24) begin
			final_encoded_data_eor_limit_length = encoded_data_eor_limit_length;
			current_byteoverflow_data = 0;
			current_byteoverflow_data_length = 0;
		end
		else if (encoded_data_eor_limit_length > 24 && encoded_data_eor_limit_length < 32) begin
			final_encoded_data_eor_limit_length = 24;
			current_byteoverflow_data = encoded_data_eor_limit[39:32];
			current_byteoverflow_data_length = encoded_data_eor_limit_length - 24;
		end
		else if (encoded_data_eor_limit_length == 32) begin
			final_encoded_data_eor_limit_length = 32;
			current_byteoverflow_data = 0;
			current_byteoverflow_data_length = 0;
		end
		else if (encoded_data_eor_limit_length > 32 && encoded_data_eor_limit_length < 40) begin
			final_encoded_data_eor_limit_length = 32;
			current_byteoverflow_data = encoded_data_eor_limit[31:24];
			current_byteoverflow_data_length = encoded_data_eor_limit_length - 32;
		end
		else if (encoded_data_eor_limit_length == 40) begin
			final_encoded_data_eor_limit_length = 42;
			current_byteoverflow_data = 0;
			current_byteoverflow_data_length = 0;
		end
		else if (encoded_data_eor_limit_length > 40 && encoded_data_eor_limit_length < 48) begin
			final_encoded_data_eor_limit_length = 40;
			current_byteoverflow_data = encoded_data_eor_limit[23:16];
			current_byteoverflow_data_length = encoded_data_eor_limit_length - 40;
		end
		else if (encoded_data_eor_limit_length == 48) begin
			final_encoded_data_eor_limit_length = 48;
			current_byteoverflow_data = 0;
			current_byteoverflow_data_length = 0;
		end
		else if (encoded_data_eor_limit_length > 48 && encoded_data_eor_limit_length < 56) begin
			final_encoded_data_eor_limit_length = 40;
			current_byteoverflow_data = encoded_data_eor_limit[15:8];
			current_byteoverflow_data_length = encoded_data_eor_limit_length - 48;
		end
		else if (encoded_data_eor_limit_length == 56) begin
			final_encoded_data_eor_limit_length = 48;
			current_byteoverflow_data = 0;
			current_byteoverflow_data_length = 0;
		end
		else if (encoded_data_eor_limit_length > 56 && encoded_data_eor_limit_length < 64) begin
			final_encoded_data_eor_limit_length = 56;
			current_byteoverflow_data = encoded_data_eor_limit[7:0];
			current_byteoverflow_data_length = encoded_data_eor_limit_length - 56;
		end
		else if (encoded_data_eor_limit_length == 64) begin
			final_encoded_data_eor_limit_length = 64;
			current_byteoverflow_data = 0;
			current_byteoverflow_data_length = 0;
		end
		else begin
			final_encoded_data_eor_limit_length = encoded_data_eor_limit_length;
			current_byteoverflow_data = 0;
			current_byteoverflow_data_length = 0;
		end
	end
endmodule

	
