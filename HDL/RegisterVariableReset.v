//Register used for pipelines
module RegisterVariableReset (clk, reset, enable, dataIn, dataOut);

	parameter size = 8;
	parameter [size - 1: 0] reset_val = 1;

	input clk, reset, enable;
	input [size - 1 : 0] dataIn;
	output reg [size - 1 : 0] dataOut;

	always @ (posedge clk) begin
		if(reset) dataOut <= reset_val;
		else begin
			if (enable) dataOut <= dataIn;
			else dataOut <= dataOut;
		end
	end
endmodule
