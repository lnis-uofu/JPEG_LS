`include "Parameterize_JPEGLS.v"

module Stage7Registers #(parameter dataOut_length = `dataOut_length,  encodedlength_width = `encodedlength_width)
			(input [dataOut_length - 1:0] dataOut_7, input [encodedlength_width - 1:0] dataSize_7, input dataReady_7, input start_enc_7,
			 input endOfDataStream_7, output [dataOut_length - 1:0] dataOut, output [encodedlength_width - 1:0] dataSize,
			 output dataReady, output endOfDataStream, input clk, input reset);

	
	defparam DataOut.size = dataOut_length;
	Register DataOut (.dataIn(dataOut_7), .dataOut(dataOut), .enable(start_enc_7 | dataReady_7), .clk(clk), .reset(reset));

	defparam DataSize.size = encodedlength_width;
	Register DataSize (.dataIn(dataSize_7), .dataOut(dataSize), .enable(start_enc_7 | dataReady_7), .clk(clk), .reset(reset));

	defparam DataReady.size = 1;
	Register DataReady (.dataIn(dataReady_7), .dataOut(dataReady), .enable(1'b1), .clk(clk), .reset(reset));

	defparam EndOfDataStream.size = 1;
	Register EndOfDataStream (.dataIn(endOfDataStream_7), .dataOut(endOfDataStream), .enable(start_enc_7 | dataReady_7), .clk(clk), .reset(reset));

endmodule
