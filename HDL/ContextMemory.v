/*
PINS
QA: Data output
DB: Data Input
AA: Read Data Adress (Context Number)
AB: Write Data Address (Context Number)
CLKA, CLKB: clk
CENA,CENB: enable input, active low (needs to be inverted)
EMAA, EMAB: Error Margin Adjustment (not used)
EMASA: Extra Margin Adjustment read port keeper enable
RET1N: Retention mode 1 enable, active-LOW
STOV: Self time override - must be active low during operaton (used for testing)

~~~~TAKEN FROM ARM MEMORY TWO PORT REGFILE COMPILER USERGUIDE~~~~

A write cycle is initiated if CENB for the write port is deasserted at the rising-edge of the clock, CLKB.
Input data is written at the specified address.

A read cycle is initiated if the read port CENA is deasserted at the rising edge of the clock, CLKA. The
data at the memory location specified by the address AA are driven on the data output bus QA. The
memory can access non-existing physical addresses, but in that case the outputs are unknown.

The memory compilers are designed to support single-cycle access, so back-to-back read and write
operations are possible. The read address for any given memory cycle can be identical to the write
address of the previous memory cycle. In that case the read data is identical to the data that was written
from the previous memory write cycle.

*/

`include "Context_Memory.v"
`include "Parameterize_JPEGLS.v"

module ContextMemory #(parameter Q_length = `Q_length, A_length = `A_length, B_length = `B_length, C_length = `C_length, N_length = `N_length, Nn_length = `Nn_length, Context_rw = `Context_rw)
		     (input clk, input [Q_length - 1:0] Q_Write, input [A_length - 1:0] A_Write, input [B_length - 1:0] B_Write, input read, input [Context_rw - 1:0] write,
		      input [C_length - 1:0] C_Write, input [N_length - 1:0] N_Write, input [Nn_length - 1:0] Nn_Write, output [A_length - 1:0] A_Read, 
		      output [B_length - 1:0] B_Read, output [C_length - 1:0] C_Read, output [N_length - 1:0] N_Read, output [Nn_length - 1:0] Nn_Read, 
		      output [Q_length - 1:0] Q_Read);

	Context_Memory A_MEM (.QA(A_Read), .CLKA(clk), .CENA(!read), .AA(Q_Read), .CLKB(clk), .CENB(!write[1] | !write[0]), .AB(Q_Write), .DB(A_Write), 
					.STOV(1'b0), .EMAA(3'b0), .EMASA(1'b0), .EMAB(3'b0), .RET1N(1'b1));

	Context_Memory B_MEM (.QA(B_Read), .CLKA(clk), .CENA(!read), .AA(Q_Read), .CLKB(clk), .CENB(!write[0]), .AB(Q_Write), .DB(B_Write), 
					.STOV(1'b0), .EMAA(3'b0), .EMASA(1'b0), .EMAB(3'b0), .RET1N(1'b1));

	Context_Memory C_MEM (.QA(C_Read), .CLKA(clk), .CENA(!read), .AA(Q_Read), .CLKB(clk), .CENB(!write[0]), .AB(Q_Write), .DB(C_Write), 
					.STOV(1'b0), .EMAA(3'b0), .EMASA(1'b0), .EMAB(3'b0), .RET1N(1'b1));

	Context_Memory N_MEM (.QA(N_Read), .CLKA(clk), .CENA(!read), .AA(Q_Read), .CLKB(clk), .CENB(!write[1] | !write[0]), .AB(Q_Write), .DB(N_Write), 
					.STOV(1'b0), .EMAA(3'b0), .EMASA(1'b0), .EMAB(3'b0), .RET1N(1'b1));

	//Nn does not actually need to be a ARM full custom memory. A simple 2-depth RF will work.
	//This memory for Nn just serves as a placeholder

	Context_Memory Nn_MEM (.QA(Nn_Read), .CLKA(clk), .CENA(!read), .AA(Q_Read), .CLKB(clk), .CENB(!write[1]), .AB(Q_Write), .DB(Nn_Write), 
					.STOV(1'b0), .EMAA(3'b0), .EMASA(1'b0), .EMAB(3'b0), .RET1N(1'b1));

endmodule
