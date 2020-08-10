vsim -voptargs="+acc" work.RiceEncodingTB 

add wave -divider {<Top Level TB>}

add wave -position insertpoint sim:/RiceEncodingTB/*

add wave -divider {<Rice Encoding>}

add wave -position insertpoint sim:/RiceEncodingTB/coder/*

add wave -divider {<Run Encoding>}

add wave -position insertpoint sim:/RiceEncodingTB/coder/Encode_Run/*

add wave -divider {<RI Encoding>}

add wave -position insertpoint sim:/RiceEncodingTB/coder/Encoded_RI_Mode/*

add wave -divider {<Normal Encoding>}

add wave -position insertpoint sim:/RiceEncodingTB/coder/Encode_Regular_Mode/*
