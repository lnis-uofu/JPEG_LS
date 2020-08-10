vsim -voptargs=+acc work.DetermineContextRead_WriteTB

add wave -divider {<Top Level TB>}

add wave -position insertpoint sim:/DetermineContextRead_WriteTB/*

add wave -divider {<Read/Write Module>}

add wave -position insertpoint sim:/DetermineContextRead_WriteTB/RW/*
