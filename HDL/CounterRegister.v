
module CounterRegister (clk, reset, dataIn, dataOut, enable);

	parameter size = 5;
	parameter default_Value = 48;

	input clk, reset, enable;

	input [size - 1 : 0] dataIn;
	
	output reg [size - 1 : 0] dataOut;

	always @ (posedge clk) begin
		if (reset) dataOut <= default_Value;
		else if (enable) dataOut <= dataIn;
		else dataOut <= dataOut;
	end

endmodule
		
