
module ParallelLoad_ShiftOut_Enable_Register (input [7:0] dataIn, input load_data, input enable_shift, input clk, input reset, output dataOut);

	reg [7:0] dataInternal;
	always @ (posedge clk) begin
		if(reset) dataInternal <= 8'b0;
		
		if (load_data) dataInternal <= dataIn;
	
		if (enable_shift) begin
			dataOut <= dataInternal [0];
			dataInternal <= dataInternal >> 1;
		end
	end
endmodule
