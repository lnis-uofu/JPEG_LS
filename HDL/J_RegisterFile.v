`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 6/23/2020
	DESCRIPTION: Register file holding the J[Run Index] values. The values range from 0 to 15.
======================================================================================================================================================================================================
*/

module J_RegisterFile #(parameter runindex_length = `runindex_length, J_length = `J_length)
		       (input [runindex_length - 1:0] run_index_control, input clk, input reset,
		        output reg [J_length - 1:0] J_Select);

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/

	wire [J_length - 1:0] J_0;
	wire [J_length - 1:0] J_1;
	wire [J_length - 1:0] J_2;
	wire [J_length - 1:0] J_3;
	wire [J_length - 1:0] J_4;
	wire [J_length - 1:0] J_5;
	wire [J_length - 1:0] J_6;
	wire [J_length - 1:0] J_7;
	wire [J_length - 1:0] J_8;
	wire [J_length - 1:0] J_9;
	wire [J_length - 1:0] J_10;
	wire [J_length - 1:0] J_11;
	wire [J_length - 1:0] J_12;
	wire [J_length - 1:0] J_13;
	wire [J_length - 1:0] J_14;
	wire [J_length - 1:0] J_15;

/* 
======================================================================================================================================================================================================
	MODULE INSTANTIATION
======================================================================================================================================================================================================
*/

	defparam J_0_Bin.RESET_VALUE = 0;
	J_Register_Bin J_0_Bin (.clk(clk), .reset(reset), .J_Bin(J_0));

	defparam J_1_Bin.RESET_VALUE = 1;
	J_Register_Bin J_1_Bin (.clk(clk), .reset(reset), .J_Bin(J_1));

	defparam J_2_Bin.RESET_VALUE = 2;
	J_Register_Bin J_2_Bin (.clk(clk), .reset(reset), .J_Bin(J_2));

	defparam J_3_Bin.RESET_VALUE = 3;
	J_Register_Bin J_3_Bin (.clk(clk), .reset(reset), .J_Bin(J_3));

	defparam J_4_Bin.RESET_VALUE = 4;
	J_Register_Bin J_4_Bin (.clk(clk), .reset(reset), .J_Bin(J_4));

	defparam J_5_Bin.RESET_VALUE = 5;
	J_Register_Bin J_5_Bin (.clk(clk), .reset(reset), .J_Bin(J_5));

	defparam J_6_Bin.RESET_VALUE = 6;
	J_Register_Bin J_6_Bin (.clk(clk), .reset(reset), .J_Bin(J_6));

	defparam J_7_Bin.RESET_VALUE = 7;
	J_Register_Bin J_7_Bin (.clk(clk), .reset(reset), .J_Bin(J_7));

	defparam J_8_Bin.RESET_VALUE = 8;
	J_Register_Bin J_8_Bin (.clk(clk), .reset(reset), .J_Bin(J_8));

	defparam J_9_Bin.RESET_VALUE = 9;
	J_Register_Bin J_9_Bin (.clk(clk), .reset(reset), .J_Bin(J_9));

	defparam J_10_Bin.RESET_VALUE = 10;
	J_Register_Bin J_10_Bin (.clk(clk), .reset(reset), .J_Bin(J_10));

	defparam J_11_Bin.RESET_VALUE = 11;
	J_Register_Bin J_11_Bin (.clk(clk), .reset(reset), .J_Bin(J_11));

	defparam J_12_Bin.RESET_VALUE = 12;
	J_Register_Bin J_12_Bin (.clk(clk), .reset(reset), .J_Bin(J_12));

	defparam J_13_Bin.RESET_VALUE = 13;
	J_Register_Bin J_13_Bin (.clk(clk), .reset(reset), .J_Bin(J_13));

	defparam J_14_Bin.RESET_VALUE = 14;
	J_Register_Bin J_14_Bin (.clk(clk), .reset(reset), .J_Bin(J_14));

	defparam J_15_Bin.RESET_VALUE = 15;
	J_Register_Bin J_15_Bin (.clk(clk), .reset(reset), .J_Bin(J_15));

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	always @ (run_index_control) begin
		case (run_index_control) /* synopsys full_case parallel_case */
			6'd0, 6'd1, 6'd2, 6'd3: J_Select = J_0;
			6'd4, 6'd5, 6'd6, 6'd7: J_Select = J_1;
			6'd8, 6'd9, 6'd10, 6'd11: J_Select = J_2;
			6'd12, 6'd13, 6'd14, 6'd15: J_Select = J_3;
			6'd16, 6'd17: J_Select = J_4;
			6'd18, 6'd19: J_Select = J_5;
			6'd20, 6'd21: J_Select = J_6;
			6'd22, 6'd23: J_Select = J_7;
			6'd24: J_Select = J_8;
			6'd25: J_Select = J_9;
			6'd26: J_Select = J_10;
			6'd27: J_Select = J_11;
			6'd28: J_Select = J_12;
			6'd29: J_Select = J_13;
			6'd30: J_Select = J_14;
			6'd31, 6'd32: J_Select = J_15;
			default: J_Select = J_0;
		endcase
	end

endmodule