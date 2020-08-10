`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

module Context_UpdateTB #(parameter A_length = `A_length, B_length = `B_length, C_length = `C_length, N_length = `N_length, Nn_length = `Nn_length,
				    modresidual_length = `modresidual_length, mode_length = `mode_length, N_Nn_Compare_length = `N_Nn_Compare_length,
				    DATA_SAMPLE_SIZE = `DATA_SAMPLE_SIZE, Context_rw = `Context_rw, Q_length = `Q_length)();

	integer i;

	reg [A_length - 1:0] A;
	reg [A_length - 1:0] A_values [DATA_SAMPLE_SIZE - 1:0];
	reg [A_length - 1:0] A_final [DATA_SAMPLE_SIZE - 1:0];
	reg [B_length - 1:0] B;
	reg [B_length - 1:0] B_values [DATA_SAMPLE_SIZE - 1:0];
	reg [B_length - 1:0] B_final [DATA_SAMPLE_SIZE - 1:0];
	reg [C_length - 1:0] C;
	reg [C_length - 1:0] C_values [DATA_SAMPLE_SIZE - 1:0];
	reg [C_length - 1:0] C_final [DATA_SAMPLE_SIZE - 1:0];
	reg [N_length - 1:0] N;
	reg [N_length - 1:0] N_values [DATA_SAMPLE_SIZE - 1:0];
	reg [N_length - 1:0] N_final [DATA_SAMPLE_SIZE - 1:0];
	reg [Nn_length - 1:0] Nn;
	reg [Nn_length - 1:0] Nn_values [DATA_SAMPLE_SIZE - 1:0];
	reg [Nn_length - 1:0] Nn_final [DATA_SAMPLE_SIZE - 1:0];
	reg resetFlag, RIType;
	reg RIType_values [DATA_SAMPLE_SIZE - 1:0];
	reg [mode_length - 1:0] mode;
	reg [mode_length - 1:0] mode_values [DATA_SAMPLE_SIZE - 1:0];
	reg [modresidual_length - 1:0] errorModulo;
	reg [modresidual_length - 1:0] errorModulo_values [DATA_SAMPLE_SIZE - 1:0];
	reg [N_Nn_Compare_length - 1:0] N_Nn_Compare_values [DATA_SAMPLE_SIZE - 1:0];
	reg B_N_Compare_values [DATA_SAMPLE_SIZE - 1:0];
	reg [Q_length - 1:0] Q;

	wire [B_length - 1:0] B_new;
	wire [A_length - 1:0] A_new;
	wire [C_length - 1:0] C_new;
	wire [Nn_length - 1:0] Nn_New;
	wire [N_length - 1:0] N_new;
	wire [N_Nn_Compare_length - 1:0] N_Nn_Compare;
	wire B_N_Compare;
	wire [Context_rw - 1:0] write_New_Context;
	wire [Q_length - 1:0] Q_new;
	

	Context_Update context_updater (.A(A), .B(B), .C(C), .N(N), .Nn(Nn), .resetFlag(resetFlag), .mode(mode), .errModulo(errorModulo),
					.B_new(B_new), .A_new(A_new), .C_new(C_new), .N_Nn_Compare(N_Nn_Compare), .RIType(RIType), .Q(Q), .Q_new(Q_new),
					.Nn_New(Nn_New), .N_new(N_new),  .B_N_Compare(B_N_Compare), .write_New_Context(write_New_Context));

	initial begin
		$readmemb("A_test.mem", A_values);
		$readmemb("B_test.mem", B_values);
		$readmemb("C_test.mem", C_values);
		$readmemb("N_test.mem", N_values);
		$readmemb("Nn_test.mem", Nn_values);
		$readmemb("A_final_test.mem", A_final);
		$readmemb("B_final_test.mem", B_final);
		$readmemb("C_final_test.mem", C_final);
		$readmemb("N_final_test.mem", N_final);
		$readmemb("Nn_final_test.mem", Nn_final);
		$readmemb("Residual_modulo_test.mem", errorModulo_values);
		$readmemb("mode_test.mem", mode_values);
		$readmemb("RIType_test.mem", RIType_values);
		$readmemb("N_Nn_Compare_test.mem", N_Nn_Compare_values);
		$readmemb("B_N_Compare_test.mem", B_N_Compare_values);
	

		resetFlag = 0;
		for (i = 0; i <= DATA_SAMPLE_SIZE - 1; i = i + 1) begin
			A = A_values[i];
			B = B_values[i];
			C = C_values[i];
			N = N_values[i];
			Nn = Nn_values[i];
			errorModulo = errorModulo_values[i];
			mode = mode_values[i];
			RIType = RIType_values[i];
			Q = 0;

			if(N == 64) resetFlag = 1;
			else resetFlag = 0;

			#10;
			$display("Iteration: %d", i + 1);
			if(A_new != A_final[i]) begin
				$display("On iteration %d A was expected to be: %d, but A was calculated as: %d", i + 1, A_final[i], A_new);
				$finish;
			end
			if(B_new != B_final[i]) begin
				$display("On iteration %d B was expected to be: %d, but B was calculated as: %d", i + 1, B_final[i], B_new);
				$finish;
			end
			if(C_new != C_final[i]) begin
				$display("On iteration %d C was expected to be: %d, but C was calculated as: %d", i + 1, C_final[i], C_new);
				$finish;
			end
			if(N_new != N_final[i]) begin
				$display("On iteration %d N was expected to be: %d, but N was calculated as: %d", i + 1, N_final[i], N_new);
				$finish;
			end
			if(Nn_New != Nn_final[i]) begin
				$display("On iteration %d Nn was expected to be: %d, but Nn was calculated as: %d", i + 1, Nn_final[i], Nn_New);
				$finish;
			end
			if(N_Nn_Compare != N_Nn_Compare_values[i]) begin
				$display("On iteration %d N_Nn_Compare was expected to be: %d, but N_Nn_Compare was calculated as: %d", i + 1, N_Nn_Compare_values[i], N_Nn_Compare);
				$finish;
			end
			if(B_N_Compare != B_N_Compare_values[i]) begin
				$display("On iteration %d B_N_Compare was expected to be: %d, but B_N_Compare was calculated as: %d", i + 1, B_N_Compare_values[i], B_N_Compare);
				$finish;
			end

			if(mode == 0) begin
				if(write_New_Context != 1) begin
					$display("Write new Context was expected to be %b, but was calculated as %b", mode + 1, write_New_Context);
					$finish;
				end
			end
			else if (mode == 2) begin
				if(write_New_Context != mode) begin
					$display("Write new Context was expected to be %b, but was calculated as %b", mode, write_New_Context);
					$finish;
				end
			end
			else begin
				if (write_New_Context != 0) begin
					$display("Write new Context was expected to be 00, but was calculated as %b", write_New_Context);
					$finish;
				end
			end
		end

		$display("Testbench finished without error");
		$finish;
	end


endmodule