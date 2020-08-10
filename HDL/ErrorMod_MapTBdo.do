vsim -voptargs=+acc work.ErrorMod_MapTB

add wave -position insertpoint sim:/ErrorMod_MapTB/*

run -all
