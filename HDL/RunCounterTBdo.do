vsim -voptargs=+acc work.RunCounterTB

add wave -position insertpoint sim:/RunCounterTB/RunCount/*
