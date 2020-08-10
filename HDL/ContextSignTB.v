`timescale 1ns/1ns
`include "ContextSign.v"

module ContextSignTB ();

	reg [8:0] Q_1, Q_2, Q_3;
	wire sign;

	ContextSign CSign (.Q_1(Q_1), .Q_2(Q_2), .Q_3(Q_3), .sign(sign));

	initial begin
		Q_1 = 0; Q_2 = 256; Q_3 = 0;
		#15;
		Q_1 = 0; Q_2 = 0; Q_3 = 256;
		#15;
		Q_1 = 256; Q_2 = 0; Q_3 = 0;
		#15;
		Q_1 = 1; Q_2 = 256; Q_3 = 0;
		#15;
		Q_1 = 0; Q_2 = 0; Q_3 = 255;
		#15;
	end

endmodule