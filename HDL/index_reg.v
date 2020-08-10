
module index_reg (increment, clk, reset, index);

	parameter size = 8;	

	input increment, clk, reset;
	output reg [size - 1 : 0] index;	

	always @ (posedge clk) begin
		if(reset) index <= 0;
		else if (increment) index <= index + 1;		
		else index <= index;
	end

endmodule
