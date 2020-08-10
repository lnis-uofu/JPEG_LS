`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module GradientQuantizationTB #(parameter quantizedQ_length = `quantizedQ_length, pixel_length = `pixel_length, DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE, mode_length = `mode_length)();


	integer i;

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/
	wire [quantizedQ_length - 1:0] D_1, D_2, D_3;
	wire sign;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/
	reg [pixel_length - 1:0] a, b, c, d;
	reg [pixel_length - 1:0] a_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] b_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] c_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [pixel_length - 1:0] d_test_values [DATA_SAMPLE_SIZE - 1:0];

	reg [quantizedQ_length - 1:0] D_1_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [quantizedQ_length - 1:0] D_2_test_values [DATA_SAMPLE_SIZE - 1:0];
	reg [quantizedQ_length - 1:0] D_3_test_values [DATA_SAMPLE_SIZE - 1:0];

	reg [mode_length - 1:0] mode_test_values [DATA_SAMPLE_SIZE - 1:0];

	reg context_sign_values [DATA_SAMPLE_SIZE - 1:0];

	GradientQuantization GradQuant (.a(a), .b(b), .c(c), .d(d), .D_1(D_1), .D_2(D_2), .D_3(D_3), .sign(sign));

	initial begin
		$readmemb("D_1_gradient_quant_test.mem", D_1_test_values);
		$readmemb("D_2_gradient_quant_test.mem", D_2_test_values);
		$readmemb("a_test.mem", a_test_values);
		$readmemb("b_test.mem", b_test_values);
		$readmemb("c_test.mem", c_test_values);
		$readmemb("d_test.mem", d_test_values);
		$readmemb("D_3_gradient_quant_test.mem", D_3_test_values);
		$readmemb("context_sign_test.mem", context_sign_values);
		$readmemb("mode_test.mem", mode_test_values);
		
		a = 0; b = 0; c = 0; d = 0;	
		#10;
		for (i = 0; i < DATA_SAMPLE_SIZE; i = i + 1) begin
			$display("Iteration %d", i + 1);
			a = a_test_values[i];
			b = b_test_values[i];
			c = c_test_values[i];
			d = d_test_values[i];

			#10;

			if(mode_test_values[i] == 0) begin
				if(D_1 != D_1_test_values[i]) begin
					$display("D_1 was expected to be %d but D_1 was calculated as %d", D_1_test_values[i], D_1);
					$finish;
				end

				if(D_2 != D_2_test_values[i]) begin
					$display("D_2 was expected to be %d but D_2 was calculated as %d", D_2_test_values[i], D_2);
					$finish;
				end

				if(D_3 != D_3_test_values[i]) begin
					$display("D_3 was expected to be %d but D_3 was calculated as %d", D_3_test_values[i], D_3);
					$finish;
				end
		
				if(context_sign_values[i] != sign) begin
					$display("Context sign was supposed to be %b, but sign was calculated as %b", context_sign_values[i], sign);
					$finish;
				end
			end
		end
		$display("TB completed without error");
		$finish;
	end

endmodule
