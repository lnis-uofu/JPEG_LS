`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"

//runmode when on last run before interrupted and hit was recorded
/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 7/25/2020
	DESCRIPTION: Encode_Pixel_With_Hit is responsible for determining run mode encoding when the next mode is a run interruption mode (next mode == 2) and the current run mode has 
		     encountered a hit with run count == run count compare. In this case, a '1' will be appened to the bitstream to signify a hit followed by a '0', which
		     will need to be appeneded to the bitstream, and finally followed by the J[Run Count] LSBs of run count.
======================================================================================================================================================================================================
*/

module Encode_Pixel_With_Hit #(parameter encodedpixel_width = `encodedpixel_width, J_length = `J_length, runcount_length = `runcount_length, encodedlength_width = `encodedlength_width)
			      (input [J_length - 1:0] J, input [runcount_length - 1:0] run_length, output reg [encodedpixel_width - 1:0] encoded_pixel);

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/

	reg process_hit_1;
	reg process_hit_2;
	reg process_hit_3;
	reg process_hit_4;
	reg process_hit_5;
	reg process_hit_6;
	reg process_hit_7;
	reg process_hit_8;
	reg process_hit_9;
	reg process_hit_10;
	reg process_hit_11;
	reg process_hit_12;
	reg process_hit_13;
	reg process_hit_14;

	reg stop_J_encoding_1;
	reg stop_J_encoding_2;
	reg stop_J_encoding_3;
	reg stop_J_encoding_4;
	reg stop_J_encoding_5;
	reg stop_J_encoding_6;
	reg stop_J_encoding_7;
	reg stop_J_encoding_8;
	reg stop_J_encoding_9;
	reg stop_J_encoding_10;
	reg stop_J_encoding_11;
	reg stop_J_encoding_12;
	reg stop_J_encoding_13;

	reg [J_length - 1:0] J_1;
	reg [J_length - 1:0] J_2;
	reg [J_length - 1:0] J_3;
	reg [J_length - 1:0] J_4;
	reg [J_length - 1:0] J_5;
	reg [J_length - 1:0] J_6;
	reg [J_length - 1:0] J_7;
	reg [J_length - 1:0] J_8;
	reg [J_length - 1:0] J_9;
	reg [J_length - 1:0] J_10;
	reg [J_length - 1:0] J_11;
	reg [J_length - 1:0] J_12;
	reg [J_length - 1:0] J_13;

	reg already_processed_hit_1;
	reg already_processed_hit_2;
	reg already_processed_hit_3;
	reg already_processed_hit_4;
	reg already_processed_hit_5;
	reg already_processed_hit_6;
	reg already_processed_hit_7;
	reg already_processed_hit_8;
	reg already_processed_hit_9;
	reg already_processed_hit_10;
	reg already_processed_hit_11;
	reg already_processed_hit_12;

	reg process_run;

/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/
			always @ (J or run_length) begin
				
				if(J > 0) begin
					process_hit_1 = 0;
					stop_J_encoding_1 = 0;
					encoded_pixel[0] = run_length[0];
					J_1 = J - 1;
				end
				else begin
					encoded_pixel[0] = 0;
					process_hit_1 = 1;
					stop_J_encoding_1 = 1;
					J_1 = J;
				end

				if(J_1 > 0 && !stop_J_encoding_1) begin
					already_processed_hit_1 = 0;
					process_hit_2 = 0;
					stop_J_encoding_2 = 0;
					encoded_pixel[1] = run_length[1];
					J_2 = J_1 - 1;
				end
				else if (J_1 == 0 && !stop_J_encoding_1) begin
					encoded_pixel[1] = 0;
					process_hit_2 = 1;
					stop_J_encoding_2 = 1;
					J_2 = J_1;
				end
				else if (process_hit_1) begin
					already_processed_hit_1 = 1;
					stop_J_encoding_2 = 1;
					encoded_pixel[1] = 1;
					process_hit_2 = 0;
					J_2 = J_1;
				end
				else begin
					already_processed_hit_1 = 0;
					encoded_pixel[1] = 0;
					process_hit_2 = 1;
					J_2 = J_1;
				end

				if(J_2 > 0 && !stop_J_encoding_2) begin
					already_processed_hit_2 = 0;
					stop_J_encoding_3 = 0;
					process_hit_3 = 0;
					encoded_pixel[2] = run_length[2];
					J_3 = J_2 - 1;
				end
				else if (J_2 == 0 && !stop_J_encoding_2) begin
					encoded_pixel[2] = 0;
					process_hit_3 = 1;
					stop_J_encoding_3 = 1;
					J_3 = J_2;
				end
				else if (process_hit_2) begin
					already_processed_hit_2 = 1;
					stop_J_encoding_3 = 1;
					encoded_pixel[2] = 1;
					process_hit_3 = 0;
				end
				else begin
					stop_J_encoding_3 = 1;
					encoded_pixel[2] = 0;
					if(already_processed_hit_1) begin
						 process_hit_3 = 0;
						 already_processed_hit_2 = 1;
					end
					else begin
						process_hit_3 = 1;
						already_processed_hit_2 = 0;
					end
					J_3 = J_2;
				end

				if(J_3 > 0 && !stop_J_encoding_3) begin
					already_processed_hit_3 = 0;
					stop_J_encoding_4 = 0;
					process_hit_4 = 0;
					encoded_pixel[3] = run_length[3];
					J_4 = J_3 - 1;
				end
				else if (J_3 == 0 && !stop_J_encoding_3) begin
					encoded_pixel[3] = 0;
					process_hit_4 = 1;
					stop_J_encoding_4 = 1;
					J_4 = J_3;
				end
				else if(process_hit_3) begin
					already_processed_hit_3 = 1;
					stop_J_encoding_4 = 1;
					encoded_pixel[3] = 1;
					process_hit_4 = 0;
					J_4 = J_3;
				end
				else begin
					stop_J_encoding_4 = 1;
					encoded_pixel[3] = 0;
					if(already_processed_hit_2) begin
						process_hit_4 = 0;
						already_processed_hit_3 = 1;
					end
					else begin
						process_hit_4 = 1;
						already_processed_hit_3 = 0;
					end
					J_4 = J_3;
				end
				

				if(J_4 > 0 && !stop_J_encoding_4) begin
					stop_J_encoding_5 = 0;
					already_processed_hit_5 = 0;
					process_hit_5 = 0;
					encoded_pixel[4] = run_length[4];
					J_5 = J_4 - 1;
				end
				else if (J_4 == 0 && !stop_J_encoding_4) begin
					encoded_pixel[4] = 0;
					process_hit_5 = 1;
					stop_J_encoding_5 = 1;
					J_5 = J_4;
				end
				else if(process_hit_4) begin
					already_processed_hit_4 = 1;
					stop_J_encoding_5 = 1;
					process_hit_5 = 0;
					encoded_pixel[4] = 1;
					J_5 = J_4;
				end
				else begin
					stop_J_encoding_5 = 1;
					encoded_pixel[4] = 0;
					if(already_processed_hit_3) begin
						process_hit_5 = 0;
						already_processed_hit_4 = 1;
					end
					else begin
						process_hit_5 = 1;
						already_processed_hit_4 = 0;
					end
					J_5 = J_4;
				end

				if(J_5 > 0 && !stop_J_encoding_5) begin
					stop_J_encoding_6 = 0;
					already_processed_hit_5 = 0;
					process_hit_6 = 0;
					encoded_pixel[5] = run_length[5];
					J_6 = J_5 - 1;
				end
				else if (J_5 == 0 && !stop_J_encoding_5) begin
					encoded_pixel[5] = 0;
					process_hit_6 = 1;
					stop_J_encoding_6 = 1;
					J_6 = J_5;
				end
				else if (process_hit_5) begin
					already_processed_hit_5 = 1;
					stop_J_encoding_6 = 1;
					process_hit_6 = 0;
					encoded_pixel[5] = 1;
					J_6 = J_5;
				end
				else begin
					stop_J_encoding_6 = 1;
					encoded_pixel[5] = 0;
					if(already_processed_hit_4) begin
						process_hit_6 = 0;
						already_processed_hit_5 = 1;
					end
					else begin
						process_hit_6 = 1;
						already_processed_hit_5 = 0;
					end
					J_6 = J_5;
				end

				if(J_6 > 0 && !stop_J_encoding_6) begin
					stop_J_encoding_7 = 0;
					already_processed_hit_6 = 0;
					process_hit_7 = 0;
					encoded_pixel[6] = run_length[6];
					J_7 = J_6 - 1;
				end
				else if (J_6 == 0 && !stop_J_encoding_6) begin
					encoded_pixel[6] = 0;
					process_hit_7 = 1;
					stop_J_encoding_7 = 1;
					J_7 = J_6;
				end
				else if(process_hit_6) begin
					already_processed_hit_6 = 1;
					stop_J_encoding_7 = 1;
					process_hit_7 = 0;
					encoded_pixel[6] = 1;
					J_7 = J_6;
				end
				else begin
					stop_J_encoding_7 = 1;
					encoded_pixel[6] = 0;
					if(already_processed_hit_5) begin
						process_hit_7 = 0;
						already_processed_hit_6 = 1;
					end
					else begin
						process_hit_7 = 1;
						already_processed_hit_6 = 0;
					end
					J_7= J_6;
				end

				if(J_7 > 0 && !stop_J_encoding_7) begin
					already_processed_hit_7 = 0;
					process_hit_8 = 0;
					stop_J_encoding_8 = 0;
					encoded_pixel[7] = run_length[7];
					J_8 = J_7 - 1;
				end
				else if (J_7 == 0 && !stop_J_encoding_7) begin
					encoded_pixel[7] = 0;
					process_hit_8 = 1;
					stop_J_encoding_8 = 1;
					J_8 = J_7;
				end
				else if(process_hit_7) begin
					stop_J_encoding_8 = 1;
					already_processed_hit_7 = 1;
					process_hit_8 = 0;
					encoded_pixel[7] = 1;
					J_8 = J_7;
				end
				else begin
					stop_J_encoding_8 = 1;
					encoded_pixel[7] = 0;
					if(already_processed_hit_6) begin
						process_hit_8 = 0;
						already_processed_hit_7 = 1;
					end
					else begin
						process_hit_8 = 1;
						already_processed_hit_7 = 0;
					end
					J_8 = J_7;
				end

				if(J_8 > 0 && !stop_J_encoding_8) begin
					already_processed_hit_8 = 0;
					process_hit_9 = 0;
					stop_J_encoding_9 = 0;
					encoded_pixel[8] = run_length[8];
					J_9 = J_8 - 1;
				end
				else if (J_8 == 0 && !stop_J_encoding_8) begin
					encoded_pixel[8] = 0;
					process_hit_9 = 1;
					stop_J_encoding_9 = 1;
					J_9 = J_8;
				end
				else if(process_hit_8) begin
					stop_J_encoding_9 = 1;
					already_processed_hit_8 = 1;
					process_hit_9 = 0;
					encoded_pixel[8] = 1;
					J_9 = J_8;
				end
				else begin
					stop_J_encoding_9 = 1;
					encoded_pixel[8] = 0;
					if(already_processed_hit_7) begin
						 process_hit_9 = 0;
						already_processed_hit_8 = 1;
					end
					else begin
						process_hit_9 = 1;
						already_processed_hit_8 = 0;
					end
					J_9 = J_8;
				end

				if(J_9 > 0 && !stop_J_encoding_9) begin
					already_processed_hit_9 = 0;
					process_hit_10 = 0;
					stop_J_encoding_10 = 0;
					encoded_pixel[9] = run_length[9];
					J_10 = J_9 - 1;
				end
				else if (J_9 == 0 && !stop_J_encoding_9) begin
					encoded_pixel[9] = 0;
					process_hit_10 = 1;
					stop_J_encoding_10 = 1;
					J_10 = J_9;
				end
				else if(process_hit_9) begin
					stop_J_encoding_10 = 1;
					already_processed_hit_9 = 1;
					process_hit_10 = 0;
					encoded_pixel[9] = 1;
					J_10 = J_9;
				end
				else begin
					stop_J_encoding_10 = 1;
					encoded_pixel[9] = 0;
					if(already_processed_hit_8) begin
						process_hit_10 = 0;
						already_processed_hit_9 = 1;
					end
					else begin
						 process_hit_10 = 1;
						already_processed_hit_9 = 0;
					end
					J_10 = J_9;
				end

				if(J_10 > 0 && !stop_J_encoding_10) begin
					already_processed_hit_10 = 0;
					stop_J_encoding_11 = 0;
					process_hit_10 = 0;
					encoded_pixel[10] = run_length[10];
					J_11 = J_10 - 1;
				end
				else if (J_10 == 0 && !stop_J_encoding_10) begin
					encoded_pixel[10] = 0;
					process_hit_11 = 1;
					stop_J_encoding_11 = 1;
					J_11 = J_10;
				end
				else if(process_hit_10) begin
					already_processed_hit_10 = 1;
					stop_J_encoding_11 = 1;
					process_hit_11 = 0;
					encoded_pixel[10] = 1;
					J_11 = J_10;
				end
				else begin
					stop_J_encoding_11 = 1;
					encoded_pixel[10] = 0;
					if(already_processed_hit_9) begin
						process_hit_11 = 0;
						already_processed_hit_10 = 1;
					end
					else begin
						process_hit_11 = 1;
						already_processed_hit_10 = 0;
					end
					J_11 = J_10;
				end

				if(J_11 > 0 && !stop_J_encoding_11) begin
					already_processed_hit_11 = 0;
					stop_J_encoding_12 = 0;
					process_hit_12 = 0;
					encoded_pixel[11] = run_length[11];
					J_12 = J_11 - 1;
				end
				else if (J_11 == 0 && !stop_J_encoding_11) begin
					encoded_pixel[11] = 0;
					process_hit_12 = 1;
					stop_J_encoding_12 = 1;
					J_12 = J_11;
				end
				else if(process_hit_11) begin
					already_processed_hit_11 = 1;
					stop_J_encoding_12 = 1;
					process_hit_12 = 0;
					encoded_pixel[11] = 1;
					J_12 = J_11;
				end
				else begin
					stop_J_encoding_12 = 1;
					encoded_pixel[11] = 0;
					if(already_processed_hit_10) begin
						process_hit_12 = 0;
						already_processed_hit_11 = 1;
					end
					else begin
						process_hit_12 = 1;
						already_processed_hit_11 = 0;
					end
					J_12 = J_11;
				end

				if(J_12 > 0 && !stop_J_encoding_12) begin
					already_processed_hit_12 = 0;
					process_hit_13 = 0;
					stop_J_encoding_13 = 0;
					encoded_pixel[12] = run_length[12];
					J_13 = J_12 - 1;
				end
				else if (J_12 == 0 && !stop_J_encoding_12) begin
					encoded_pixel[12] = 0;
					process_hit_13 = 1;
					stop_J_encoding_13 = 1;
					J_13 = J_12;
				end
				else if(process_hit_12) begin
					already_processed_hit_12 = 1;
					stop_J_encoding_13 = 1;
					process_hit_13 = 0;
					encoded_pixel[12] = 1;
					J_13 = J_12;
				end
				else begin
					stop_J_encoding_13 = 1;
					encoded_pixel[12] = 0;
					if(already_processed_hit_11) begin
						process_hit_13 = 0;
						already_processed_hit_12 = 1;
					end
					else begin
						process_hit_13 = 1;
						already_processed_hit_12 = 0;
					end
					J_13 = J_12;
				end

				if(J_13 > 0 && !stop_J_encoding_13) begin
					encoded_pixel[13] = run_length[13];
					process_hit_14 = 0;
					process_run = 1;
				end
				else if (J_13 == 0 && !stop_J_encoding_13) begin
					encoded_pixel[13] = 0;
					process_hit_14 = 1;
				end
				else if(process_hit_13) begin
					encoded_pixel[13] = 1;
					process_run = 0;
					process_hit_14 = 0;
				end
				else begin 
					encoded_pixel[13] = 0;
					process_run = 0;
					if(already_processed_hit_12)process_hit_14 = 0;
					else process_hit_14 = 1;
				end
			
				
				if(process_run) begin
					encoded_pixel[14] = 0;
					encoded_pixel[15] = 1;
					encoded_pixel[encodedpixel_width - 1 : 16] = 0;
				end
				else if(process_hit_14) begin
					encoded_pixel[14] = 1;
					encoded_pixel[encodedpixel_width - 1 : 15] = 0;
				end
				else begin
					encoded_pixel[encodedpixel_width - 1 : 14] = 0;
				end
		end
endmodule