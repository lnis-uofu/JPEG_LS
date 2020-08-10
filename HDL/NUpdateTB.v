`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module NUpdateTB #(parameter N_length = `N_length)();

	integer i;

	reg [N_length - 1:0] N;
	reg [N_length - 1:0] N_Compare;
	wire resetFlag;
	wire [N_length - 1:0] N_New;

	NUpdate updater (.N(N), .resetFlag(resetFlag), .N_New(N_New));

	initial begin
		N_Compare = 33;
		for(i = 1; i <= 65; i = i + 1) begin
			N = 1;
			if (N > 64) begin
				if (N_New != N_Compare) begin
					$display("N is not reset correctly");
					$finish;
				end
				if (!resetFlag) begin
					$display("Reset flag is not set when reset of auxiliary context variables is needed");
					$finish;
				end
			end
			else begin
				if ((N+1) != N_New) begin
					$display("N is not incremented correctly");
					$finish;
				end
				if(resetFlag) begin
					$display("Reset flag is set when reset of auxiliary context variables is not needed");
					$finish;
				end
			end
		end
		$display("No errors detected");
		$finish;
	end
endmodule
