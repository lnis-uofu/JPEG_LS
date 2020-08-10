vsim -voptargs=+acc work.RunCoderTB

add wave -position insertpoint sim:/RunCoderTB/*

add wave -divider {<Run Coder>}

add wave -position insertpoint sim:/RunCoderTB/Run_Coder/*

add wave -divider {<J Calculation>}

add wave -position insertpoint sim:/RunCoderTB/Run_Coder/J_Selection/*

bp ./RunCoderTB.v 759

examine sim:/RunCoderTB/Counter_Values

run -all
