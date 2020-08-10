`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module ModeDeterminationTB #(parameter pixel_length = `pixel_length, mode_length = `mode_length, DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE)();


	integer i;

	reg [pixel_length - 1:0] a, b, c, d, x;
	reg EOL;
	reg clk;
	reg reset;
	reg start_enc;
	
	wire [mode_length - 1:0] mode;

	reg [pixel_length - 1:0] a_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] b_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] c_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] d_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] x_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg EOL_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [mode_length - 1:0] mode_test_values [DATA_SAMPLE_SIZE - 1:0];

	ModeDetermination ModeDeter (.a(a), .b(b), .c(c), .d(d), .x(x), .EOL(EOL), .mode(mode), .clk(clk), .reset(reset), .start_enc(start_enc));

	always #5 clk = !clk;

	initial begin

		$readmemb("a_test.mem", a_test_values);
		$readmemb("b_test.mem", b_test_values);
		$readmemb("c_test.mem", c_test_values);
		$readmemb("d_test.mem", d_test_values);
		$readmemb("x_test.mem", x_test_values);
		$readmemb("mode_test.mem", mode_test_values);
		$readmemb("EOL_test.mem", EOL_test_values);

		start_enc = 0;
		clk = 0;
		reset = 0;
		#11
		reset = 1;
		#10;
		reset = 0;
		#10;

		for(i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin
			
			$display("Iteration: %d", i + 1);
			
			@(posedge clk) a = a_test_values[i];
			b = b_test_values[i];
			c = c_test_values[i];
			d = d_test_values[i];
			x = x_test_values[i];
			EOL = EOL_test_values[i];
			start_enc = 1;

			#5;

			if(mode != mode_test_values[i]) begin
				$display("Mode was expected to be %d but was calculated as %d", mode_test_values[i], mode);
				$finish;
			end

		end
		$display("TB completed without error");
		$finish;
	end

endmodule
