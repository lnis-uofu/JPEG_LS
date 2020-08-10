`include "Parameterize_JPEGLS.v"

module J_Register_Bin (clk, reset, J_Bin);
	localparam J_length = `J_length;
	parameter [J_length - 1:0] RESET_VALUE;

	input clk;
	input reset;
	output reg [J_length - 1:0] J_Bin;

	always @ (posedge clk) begin
		if(reset) J_Bin <= RESET_VALUE;
		else J_Bin <= J_Bin;
	end
endmodule