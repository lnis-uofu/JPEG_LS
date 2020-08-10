
module context_reg (input clk, input reset, input enable, input [7:0] dataIn, 
	            output reg [7:0] dataOut);

	always @ (posedge clk) begin
		if(reset) dataOut <= 8'b0;
		else begin
			if (enable) dataOut <= dataIn;
		end
	end
endmodule
