vsim -voptargs=+acc work.RunLengthAdjustTB

add wave -position insertpoint sim:/RunLengthAdjustTB/AdjustRL/*

run -all

