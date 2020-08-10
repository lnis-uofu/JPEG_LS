`include "Parameterize_JPEGLS.v"
//This will need to be updated to map to your Designware library location
`include "/uusoc/facility/cad_common/Synopsys/syn_vM-2016.12-SP3/dw/dw01/src_ver/DW01_bsh.v"

module BarrelShifter (PreShiftData, ShiftAmount, PostShiftData);

	parameter SHIFT_DATA_LENGTH = 56;

	parameter SHIFT_WIDTH = 6;

	input [SHIFT_DATA_LENGTH - 1:0] PreShiftData;
	input [SHIFT_WIDTH - 1:0] ShiftAmount;
	output [SHIFT_DATA_LENGTH - 1:0] PostShiftData;

 	DW01_bsh #(SHIFT_DATA_LENGTH, SHIFT_WIDTH)    	U1 ( .A(PreShiftData), .SH(ShiftAmount), .B(PostShiftData));

endmodule


	


