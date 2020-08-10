vsim -voptargs="+acc" work.GetDataFSMTB

add wave -divider {<Top Level TB>}

add wave -position insertpoint sim:/GetDataFSMTB/*

add wave -divider {<GetDataFSM>}

add wave -position insertpoint sim:/GetDataFSMTB/DataFSM/*


