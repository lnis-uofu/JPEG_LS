`timescale 1ns/1ns
`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

/*
8 * 135 = 1080 bits
*/

module GetDataFSMTB #(parameter pixel_length = `pixel_length, DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE) ();

	localparam TOTAL_NUM_BITS_ROW = 1080;
	localparam NUM_OF_ROWS = 311;
	localparam TOTAL_BYTES_MEM = 335880;

	integer MEM_ONE_OFFSET, MEM_TWO_OFFSET;
	integer MEM_PREV_ONE_OFFSET, MEM_PREV_TWO_OFFSET;

	reg clk, reset, start;
	wire [pixel_length - 1:0] pixelIn;
	wire [pixel_length - 1:0] prevPixelIn;
	wire start_enc;
	wire [pixel_length - 1:0] a_1, b_1, c_1, d_1, x_1;
	wire [pixel_length - 1:0] col_index, prev_col_index;
	wire read_MEM_ONE, read_PREV_MEM_ONE;
	wire read_MEM_TWO, read_PREV_MEM_TWO;
	wire EOF_1, EOL_1;

	reg [pixel_length - 1:0] a_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] b_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] c_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] d_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] x_test_values [DATA_SAMPLE_SIZE - 1:0];

	reg [pixel_length - 1:0] pixelInDelay;
	reg [pixel_length - 1:0]  prevPixelInDelay;
	reg [pixel_length - 1:0] MEM_ONE [TOTAL_BYTES_MEM - 1:0];
	reg [pixel_length - 1:0] MEM_TWO [TOTAL_BYTES_MEM - 1:0];
	
	integer mem_one_index, mem_two_index;

	integer i;

	assign #5 prevPixelIn = prevPixelInDelay;
	assign #5 pixelIn = pixelInDelay;

	GetDataFSM DataFSM (.clk(clk), .reset(reset), .start(start), .pixelIn(pixelIn), .prevPixelIn(prevPixelIn), .start_enc(start_enc),
			    .a(a_1), .b(b_1), .c(c_1), .d(d_1), .x(x_1), .read_MEM_ONE(read_MEM_ONE), 
			    .read_MEM_TWO(read_MEM_TWO), .read_PREV_MEM_ONE(read_PREV_MEM_ONE), .EOF(EOF_1), .EOL(EOL_1),
			    .read_PREV_MEM_TWO(read_PREV_MEM_TWO),.col_index(col_index), .prev_col_index(prev_col_index));

	initial begin
		$readmemb("a_test.mem", a_test_values);
		$readmemb("b_test.mem", b_test_values);
		$readmemb("c_test.mem", c_test_values);
		$readmemb("d_test.mem", d_test_values);
		$readmemb("x_test.mem", x_test_values);
		$readmemb("image_one_final_data.mem", MEM_ONE);
		$readmemb("image_two_final_data.mem", MEM_TWO);

		i = 0;
		clk = 0;
		reset = 0;
		start = 0;
		pixelInDelay = 0;
		prevPixelInDelay = 0;
		MEM_ONE_OFFSET = 0;
		MEM_TWO_OFFSET = 0;
		MEM_PREV_ONE_OFFSET = 0;
		MEM_PREV_TWO_OFFSET = 0;
		#5;
		reset = 1;
		#16;
		reset = 0;
		start = 1;

	end

	always #10 clk = ~clk;  

	always @ (posedge clk) begin
		if(read_MEM_ONE) pixelInDelay = MEM_ONE[(MEM_ONE_OFFSET * 135) + col_index];
		else if(read_PREV_MEM_ONE) prevPixelInDelay = MEM_ONE[(MEM_PREV_ONE_OFFSET * 135) + prev_col_index];

		if(MEM_ONE_OFFSET == 0 && col_index == 135 && read_MEM_ONE) begin
			MEM_ONE_OFFSET = MEM_ONE_OFFSET + 1;
		end
		else if(col_index == 136 && read_MEM_ONE) begin
			MEM_ONE_OFFSET = MEM_ONE_OFFSET + 1;
		end

		if(prev_col_index == 135 && read_PREV_MEM_ONE) begin
			MEM_PREV_ONE_OFFSET = MEM_PREV_ONE_OFFSET + 1;
		end
	end


	always @ (posedge clk) begin
		if(read_MEM_TWO) pixelInDelay = MEM_TWO[(MEM_TWO_OFFSET * 135) + col_index];
		else if(read_PREV_MEM_TWO) prevPixelInDelay = MEM_TWO[(MEM_PREV_TWO_OFFSET * 135) + prev_col_index];

		if(col_index == 136 && read_MEM_TWO) begin
			MEM_TWO_OFFSET = MEM_TWO_OFFSET + 1;
		end

		if(prev_col_index == 135 && read_PREV_MEM_TWO) begin
			MEM_PREV_TWO_OFFSET = MEM_PREV_TWO_OFFSET + 1;
		end
	end

	always @ (col_index or prev_col_index or start_enc) begin
		#5; //need internal delay
		if(i < DATA_SAMPLE_SIZE) begin
			if(start_enc) begin

				$display("Iteration %d", i + 1);
				
				if (x_1 != x_test_values[i]) begin
					$display("X was expected to be %d, but was calculated as %d", x_test_values[i], x_1);
					$finish;
				end
				if (a_1 != a_test_values[i]) begin
					$display("A was expected to be %d, but was calculated as %d", a_test_values[i], a_1);
					$finish;
				end
		
				if (b_1 != b_test_values[i]) begin
					$display("B was expected to be %d, but was calculated as %d", b_test_values[i], b_1);
					$finish;
				end
		
				if(c_1 != c_test_values[i]) begin
					$display("C was expected to be %d, but was calculated as %d", c_test_values[i], c_1);
					$finish;
				end

				if(d_1 != d_test_values[i]) begin
					$display("D was expected to be %d, but was calculated as %d", d_test_values[i], d_1);
					$finish;
				end
				i = i + 1;
			end
		end
		else begin
			$display("TB completed without error");
			$finish;
		end
	end


endmodule

	
