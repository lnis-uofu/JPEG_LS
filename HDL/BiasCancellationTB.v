`timescale 1ns/1ns

module BiasCancellationTB();

	reg [6:0] A, B, C, N, Nn;


	BiasCancellation bias_cancel (.A(A), .B(B), .C(C), .N(N), .Nn(Nn), .B_new(B_new), .A_new(A_new), .C_new(C_new), .N_new(N_new),
					.resetFlag(resetFlag), .errValue(errorModulo), .RIType(RIType), .Nn_new(Nn_New));

endmodule