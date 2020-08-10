`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Context Sign determination of Context Vector. If the first non-zero element of the vector (Q1, Q2, Q3) is negative, then all the signs of the vector (Q1, Q2, Q3) 
		     shall be reversed to obtain (?Q1, ?Q2, ?Q3). To ensure this a priority blocked scheme is needed.
======================================================================================================================================================================================================
*/
module ContextSign #(parameter Q_length = `Q_length)
		    (input [Q_length - 1:0] Q_1, input [Q_length - 1:0] Q_2, input [Q_length - 1:0] Q_3, output reg sign);

	always @ (Q_1 or Q_2 or Q_3) begin
		sign = 0;
		if(Q_1 != 0) begin
			if (Q_1[Q_length - 1] == 1) sign = 1;
		end
		else if (Q_2 != 0) begin
			if (Q_2[Q_length - 1] == 1) sign = 1;
		end
		else if (Q_3 != 0) begin
			if (Q_3[Q_length - 1] == 1) sign = 1;
		end
	end
endmodule

