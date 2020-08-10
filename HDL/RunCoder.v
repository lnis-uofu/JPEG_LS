`timescale 1ns/1ns
`include "Parameterize_JPEGLS.v"
`include "J_RegisterFile.v"

/* 
======================================================================================================================================================================================================
	AUTHOR: GRANT BROWN (LNIS)
	DATE: 4/18/2020
	DESCRIPTION: Encode Run Interruption run count depending on the number of hits of a shift oriented comparison is met. Each time a comparison or runlength of rg (2^k) is met
		     it is needed to append a 1 to the bit stream which corresponds to a hit in this context. The run index should be increased up to a maximum value of 32. To hide stalls and
		     ensure seamless transition from run mode to run interruption coding the index is fed back from pipeline registers. When a run index of 2^k is met then it is needed to 
		     increment the run index for the next comparion value. Run index is needed in the Golomb coding for comparion of maximum encoding length.

	Notes:
		Run Counter compare needs to be reset to 1

	USES:   J_run_count_compare - used to update run_count_compare_decision_new when mode == 2
		run_count_compare_decision_new - When a run interruption is met we will count the number of hits (done while running) and then encode the number of 1's and run mode,
						 then J(run_index) is immediately updated for the next mode. What this does is take the current J (J_Comp) and if its an edge case
						 will subtract 1 from J_Comp to move it to the previous bin. This updates run_count_compare on the same cycle as mode == 2. This is then saved to
						 a register (run_count_compare_decision) which is then used as the hit case for the next mode after mode == 2 (when previous_mode == 2)
		J_Comp - Previously J, J gets updated but needs to reflect the next clock cycle, the current J is essentially the previous J then
		run_index_decision_new - Run_index gets updated when mode == 2 to be - 1 of the current value. Now the run index should not updated until after the mode 2 encoding is done
					 so it is stored into a register which delays it by 1 clock cycle and the value appears at run_index_decision when previous_mode == 2. When there are 
					 multiple run interruption modes in a row then we update the previous run_index_decision variable since that variable was previously updated and does
					 not appear at run_index yet, since it is delayed a clock cycle
		J_Recurring_Mode_2 - Works like a cascade affect. When previous_mode == 2 and mode == 2 we will set run_index_new to run_index_decision_new or run_index_decision.
				     Run_index_decision is the run_index that was saved from the decrement of the previous mode == 2. This is the delayed decrement of the run index.
				     Therefore then the current run index (which was the previous decremented by 1) is updated which then cascades to update J (J_new). This then is the 
				     J that should be saved from the previous mode == 2 (but we cant decrement on the previous mode == 2 since J stable is needed for the run encoding. 
				     Therefore it is essentially just the delayed decrement of the run_index mapping to J (J(run_index_delay))
		remainder_subtract_accum - When a run is going we will need to accumulate the total run count sum for the hits generated during the run. This is then subtracted from
					   the run count determining any run overflow from the last hit. This is needed in the encoding of the end of run (run_length_remainder, J(run_index))
					
======================================================================================================================================================================================================
*/
module RunCoder #(parameter runcount_length = `runcount_length, runindex_length = `runindex_length, mode_length = `mode_length, J_length = `J_length)
		(input [runcount_length - 1:0] run_counter, input [runcount_length - 1:0] run_counter_compare, input [runindex_length - 1:0] run_index, 
		 input [mode_length - 1:0] mode, input clk, input reset, output reg hit, output reg [runindex_length - 1:0] run_index_new, output [mode_length - 1:0] previous_mode,
		 output [runcount_length - 1:0] run_length, output reg [runcount_length - 1:0] run_counter_compare_new, output reg [J_length - 1:0] J, output [J_length - 1:0] J_Comp,
		 output [runcount_length - 1:0] remainder_subtract, output [J_length - 1:0] J_Recurring_Mode_2, input start_enc, input [runcount_length - 1:0] remainder_subtract_accum);

/* 
======================================================================================================================================================================================================
	WIRE DECLARATION
======================================================================================================================================================================================================
*/
	wire [runindex_length - 1:0] run_index_decision;
	wire [runcount_length - 1:0] run_count_compare_decision;

	wire [runcount_length - 1:0] run_count_compare_decision_new;
	wire [runindex_length - 1:0] run_index_decision_new;

	wire [J_length - 1:0] J_new;

/* 
======================================================================================================================================================================================================
	REG DECLARATION
======================================================================================================================================================================================================
*/

	reg [J_length - 1:0] J_run_count_compare;

	reg [runindex_length - 1:0] run_index_reset_compare;

/* 
======================================================================================================================================================================================================
	MODULE INSTANTIATION
======================================================================================================================================================================================================
*/
	defparam Previous_Mode.size = mode_length;
	Register Previous_Mode (.dataIn(mode), .dataOut(previous_mode), .enable(start_enc), .clk(clk), .reset(reset));

	//may not need
	defparam J_Value.size = J_length;
	Register J_Value (.dataIn(J_new), . dataOut(J_Comp), .enable(start_enc), .clk(clk), .reset(reset));

	defparam Run_Count_Compare_Decision.size = runcount_length;
	Register Run_Count_Compare_Decision (.dataIn(run_count_compare_decision_new), . dataOut(run_count_compare_decision), .enable(start_enc), .clk(clk), .reset(reset));

	defparam Run_Index_Decision.size = runindex_length;
	Register Run_Index_Decision (.dataIn(run_index_decision_new), . dataOut(run_index_decision), .enable(start_enc), .clk(clk), .reset(reset));

	RemainderSubtractAccum Remainder_Accum (.J(J_Comp), .mode(mode), .previous_mode(previous_mode), .clk(clk), .reset(reset), .run_counter(run_counter),
						.run_counter_compare(run_counter_compare), .run_count_compare_decision(run_count_compare_decision),
			 			.remainder_subtract_accum(remainder_subtract_accum), .remainder_subtract(remainder_subtract));

	J_RegisterFile J_Selection (.clk(clk), .reset(reset), .run_index_control(run_index_reset_compare), .J_Select(J_new));



/* 
======================================================================================================================================================================================================
	COMBINATIONAL LOGIC
======================================================================================================================================================================================================
*/

	assign run_count_compare_decision_new = (1 << J_run_count_compare);
	assign run_index_decision_new = (mode == 2) ? (previous_mode == 2) ? ((run_index_decision > 0) ?  run_index_decision - 1 :  run_index_decision) : ((run_index > 0) ?  run_index - 1 :  run_index) : run_index;
	assign J_Recurring_Mode_2 = J_new;
	assign run_length = run_counter;

	always @ (mode or previous_mode or run_index or run_index_decision or J_Comp) begin
		J_run_count_compare = J_Comp;

		if (mode == 2 && previous_mode != 2) begin
			if(run_index == 4 || run_index == 8 || run_index == 12 || run_index == 16 || run_index == 18 ||
			   run_index == 20 || run_index == 22 || run_index >= 24) begin
				J_run_count_compare = J_Comp - 1;
			end
		end
		else if (previous_mode == 2 && mode == 2) begin			
			if(run_index_decision == 4 || run_index_decision == 8 || run_index_decision == 12 || run_index_decision == 16 || run_index_decision == 18 ||
			   run_index_decision == 20 || run_index_decision == 22 || run_index_decision >= 24) begin
				J_run_count_compare = J_Comp - 1;
			end
		end
	end


	// each of these values of of length rg, each time the run count hits one of these values the run index is incremented
	// that means the the values of J must be an accumulation of the values from before it (ACC)
	always @ (run_index_new or mode or previous_mode) begin
		if(mode == 2 && previous_mode != 2 && run_index_new > 0) run_index_reset_compare = run_index_new - 1;		
		else if (previous_mode == 2 && mode == 2) run_index_reset_compare = run_index_new;
		else run_index_reset_compare = run_index_new;	
	end



	always @ (run_counter or mode or run_index_decision_new or previous_mode or J_Comp or run_index_decision) begin
		hit = 0;

/* 
======================================================================================================================================================================================================
	Needs to be sequential analysis. J will be updated on the current iteration for run counter compare incrementing. This is essential to happen before the mode analysis is started
	so as to remove any cyclic behavior. Synthesis should create parallel arithmetic for mode analysis.
======================================================================================================================================================================================================
*/
		if ((run_counter == run_counter_compare && previous_mode != 2) || (run_counter == (1 << J_Comp) && previous_mode == 3)) begin
			case (run_index)
				6'd3: J = J_Comp + 1;
				6'd7: J = J_Comp + 1;
				6'd11: J = J_Comp + 1;
				6'd15: J = J_Comp + 1;
				6'd17: J = J_Comp + 1;
				6'd19: J = J_Comp + 1;
				6'd21: J = J_Comp + 1;
				6'd23: J = J_Comp + 1;
				6'd24: J = J_Comp + 1;
				6'd25: J = J_Comp + 1;
				6'd26: J = J_Comp + 1;
				6'd27: J = J_Comp + 1;
				6'd28: J = J_Comp + 1;
				6'd29: J = J_Comp + 1;
				6'd30: J = J_Comp + 1;
				default: J = J_Comp;
			endcase
		end
		else if (run_counter == run_count_compare_decision && previous_mode == 2) begin
			case (run_index_decision)
				6'd3: J = J_Comp + 1;
				6'd7: J = J_Comp + 1;
				6'd11: J = J_Comp + 1;
				6'd15: J = J_Comp + 1;
				6'd17: J = J_Comp + 1;
				6'd19: J = J_Comp + 1;
				6'd21: J = J_Comp + 1;
				6'd23: J = J_Comp + 1;
				6'd24: J = J_Comp + 1;
				6'd25: J = J_Comp + 1;
				6'd26: J = J_Comp + 1;
				6'd27: J = J_Comp + 1;
				6'd28: J = J_Comp + 1;
				6'd29: J = J_Comp + 1;
				6'd30: J = J_Comp + 1;
				default: J = J_Comp;
			endcase
		end
		else begin
			J = J_Comp;
		end

		if ((mode == 1 || mode == 3) && previous_mode != 2 && previous_mode !=3) begin
			if(run_counter == run_counter_compare) begin
				if(run_index < 6'd32) run_index_new = run_index + 1;
				else run_index_new = run_index;

				// ACC Operation here
				run_counter_compare_new = run_counter_compare +  (1 << J);

				//This is the value to be encoded by the run count (how many 1's we append to bitstream)
				hit = 1;
			end
			else begin
				run_index_new = run_index;
				run_counter_compare_new = run_counter_compare;
			end
		end
		else if (previous_mode == 2) begin
			if (mode == 1 || mode == 3) begin
				if(run_counter == run_count_compare_decision) begin
					if(run_index < 6'd32) run_index_new = run_index_decision + 1;
					else run_index_new = run_index_decision;

					// ACC Operation here
					run_counter_compare_new = run_count_compare_decision +  (1 << J);

					//This is the value to be encoded by the run count (how many 1's we append to bitstream)
					hit = 1;
				end	
				else begin
					run_index_new = run_index_decision;
					run_counter_compare_new = run_count_compare_decision;
				end
			end
			else if (mode == 2) begin
				//what we are doing here is undecrementing the run_index so as to update J from the previous iteration. J is important as it is used in
				//determining the runlength bits that will be appended to the encoded pixel
				run_index_new = run_index_decision_new + 1;
			end
			else begin
				run_index_new = run_index_decision;
				run_counter_compare_new = run_count_compare_decision;
			end
		end
		else if (previous_mode == 3 && mode == 1) begin
			if(run_counter == (1 << J_Comp)) begin
				if(run_index < 6'd32) run_index_new = run_index + 1;
				else run_index_new = run_index;

				run_counter_compare_new = run_counter + (1 << J);
				//This is the value to be encoded by the run count (how many 1's we append to bitstream)
				hit = 1;
			end
			else begin
				run_index_new = run_index;
				run_counter_compare_new = (1 << J_Comp);
			end
		end
		else if (previous_mode == 3 && mode == 0) begin
			run_index_new = run_index;
			run_counter_compare_new = (1 << J_Comp);
		end
		else begin
			run_index_new = run_index;
			run_counter_compare_new = run_counter_compare;
		end
	end

endmodule
