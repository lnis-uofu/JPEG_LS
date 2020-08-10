`include "Parameterize_JPEGLS.v"

module Stage6Registers #(parameter encodedpixel_width = `encodedpixel_width, encodedlength_width = `encodedlength_width, remaindervalue_length = `remaindervalue_length,
				   J_length = `J_length, mode_length = `mode_length)
			(input clk, input reset, input [encodedpixel_width - 1:0] encoded_pixel_6, input [encodedlength_width - 1:0] encoded_length_6, input EOF_6, 
			 input limit_overflow_6, input start_enc_6, output [encodedpixel_width - 1:0] encoded_pixel_7, output [encodedlength_width - 1:0] encoded_length_7,
			 output EOF_7, output limit_overflow_7, output start_enc_7, input [remaindervalue_length - 1:0] remainder_value_6, 
			 output [remaindervalue_length - 1:0] remainder_value_7, input do_run_encoding_6, input [J_length - 1:0] J_6, output [J_length - 1:0] J_7,
			 input [mode_length - 1:0] mode_6, output [mode_length - 1:0] mode_7);


	defparam Encoded_Pixel.size = encodedpixel_width;
	Register Encoded_Pixel (.dataIn(encoded_pixel_6), .dataOut(encoded_pixel_7), .enable(start_enc_6 | do_run_encoding_6), .clk(clk), .reset(reset));

	defparam Encoded_Length.size = encodedlength_width;
	Register Encoded_Length (.dataIn(encoded_length_6), .dataOut(encoded_length_7), .enable(start_enc_6 | do_run_encoding_6), .clk(clk), .reset(reset));

	defparam EOF.size = 1;
	Register EOF (.dataIn(EOF_6), .dataOut(EOF_7), .enable(start_enc_6), .clk(clk), .reset(reset));

	defparam Limit_Overflow.size = 1;
	Register Limit_Overflow (.dataIn(limit_overflow_6), .dataOut(limit_overflow_7), .enable(start_enc_6), .clk(clk), .reset(reset));

	defparam Start_Enc.size = 1;
	Register Start_Enc (.dataIn(start_enc_6), .dataOut(start_enc_7), .enable(1'b1), .clk(clk), .reset(reset));

	defparam Remainder_Value.size = remaindervalue_length;
	Register Remainder_Value (.dataIn(remainder_value_6), .dataOut(remainder_value_7), .enable(start_enc_6), .clk(clk), .reset(reset));

	defparam J.size = J_length;
	Register J (.dataIn(J_6), .dataOut(J_7), .enable(start_enc_6), .clk(clk), .reset(reset));

	defparam Mode.size = mode_length;
	Register Mode (.dataIn(mode_6), .dataOut(mode_7), .enable(start_enc_6), .clk(clk), .reset(reset));

endmodule
