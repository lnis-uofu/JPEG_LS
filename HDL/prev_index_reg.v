
module prev_index_reg (increment, clk, reset, index);

	parameter size = 8;	

	input increment, clk, reset;
	output reg [size - 1 : 0] index;	

	always @ (posedge clk) begin
		if(reset) index <= 2;
		else if (increment) begin
			index <= index + 1;
		end
	end

endmodule