create_clock -name core_clock -period 10 [get_ports clk]

set_input_delay  1.0 -clock core_clock [get_ports reset]
set_input_delay  2.5 -clock core_clock [get_ports {Instr[*]}]
set_input_delay  9.0 -clock core_clock [get_ports {ReadData[*]}]

set_output_delay 9.0 -clock core_clock [get_ports {Pc[*]}]
set_output_delay 2.5 -clock core_clock [get_ports {ALUResult[*]}]
set_output_delay 0.5 -clock core_clock [get_ports {WriteData[*]}]
set_output_delay 0.5 -clock core_clock [get_ports MemWrite]
