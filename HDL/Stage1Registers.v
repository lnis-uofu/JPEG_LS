`include "Parameterize_JPEGLS.v"

module Stage1Registers #(parameter pixel_length = `pixel_length)
			(input clk, input reset, input [pixel_length - 1:0] a_1, input [pixel_length - 1:0] b_1, input [pixel_length - 1:0] c_1, input [pixel_length - 1:0] d_1, 
			 input [pixel_length - 1:0] x_1 , input EOL_1, input EOF_1, input start_enc_1, output [pixel_length - 1:0] a_2, output [pixel_length - 1:0] b_2, 
			 output [pixel_length - 1:0] c_2, output [pixel_length - 1:0] d_2, output [pixel_length - 1:0] x_2 , output EOL_2, output EOF_2, output start_enc_2);

	Register A (.dataIn(a_1), .dataOut(a_2), .enable(start_enc_1), .clk(clk), .reset(reset));
	Register B (.dataIn(b_1), .dataOut(b_2), .enable(start_enc_1), .clk(clk), .reset(reset));
	Register C (.dataIn(c_1), .dataOut(c_2), .enable(start_enc_1), .clk(clk), .reset(reset));
	Register D (.dataIn(d_1), .dataOut(d_2), .enable(start_enc_1), .clk(clk), .reset(reset));
	Register X (.dataIn(x_1), .dataOut(x_2), .enable(start_enc_1), .clk(clk), .reset(reset));

	defparam EOL.size = 1;
	Register EOL (.dataIn(EOL_1), .dataOut(EOL_2), .enable(start_enc_1), .clk(clk), .reset(reset));

	defparam EOF.size = 1;
	Register EOF (.dataIn(EOF_1), .dataOut(EOF_2), .enable(start_enc_1), .clk(clk), .reset(reset));

	defparam Start_Enc.size = 1;
	Register Start_Enc (.dataIn(start_enc_1), .dataOut(start_enc_2), .enable(1'b1), .clk(clk), .reset(reset));

endmodule
