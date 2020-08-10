//Register used for pipelines
module Register (clk, reset, enable, dataIn, dataOut);

	parameter size = 8;

	input clk, reset, enable;
	input [size - 1 : 0] dataIn;
	output reg [size - 1 : 0] dataOut;

	always @ (posedge clk) begin
		if(reset) dataOut <= 0;
		else begin
			if (enable) dataOut <= dataIn;
			else dataOut <= dataOut;
		end
	end
endmodule
