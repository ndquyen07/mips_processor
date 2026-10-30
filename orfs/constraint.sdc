# constraint.sdc -- timing constraints for the MIPS single-cycle core (top: mips)
#
# Units: ns, inherited from the sky130hd liberty file (time_unit 1ns).
#
# The core has no memory inside. Instruction memory and data memory sit
# outside the core, so their timing enters here as input and output delays.
#
# Given (assumed: no real chip spec, no real memory datasheet):
#   clock period               10.0 ns
#   instruction memory read     1.5 ns
#   data memory read            1.5 ns
#   data memory write setup     0.5 ns
#
# Budget for one lw instruction in one cycle (times from the clock edge):
#   0.0 -> 1.0   PC flop to Pc port                          (core)
#   1.0 -> 2.5   instruction memory read                     (outside)
#   2.5 -> 6.5   Instr -> regfile -> ALU -> ALUResult port   (core, 4.0 ns)
#   6.5 -> 8.0   data memory read                            (outside)
#   8.0 -> 10.0  ReadData -> mux -> regfile D pin, incl. setup (core, 2.0 ns)

current_design mips

set clk_name core_clock
set clk_port_name clk
set clk_period 10

set clk_port [get_ports $clk_port_name]

create_clock -name $clk_name -period $clk_period $clk_port
set clk_io_name vclk_$clk_name
create_clock -name $clk_io_name -period $clk_period

set_clock_latency 0.290 [get_clocks $clk_name]
set_clock_latency 0.290 [get_clocks $clk_io_name]


set_input_delay 2.5 -clock $clk_io_name [get_ports {Instr[*]}]
set_input_delay 8.0 -clock $clk_io_name [get_ports {ReadData[*]}]
set_input_delay 2.0 -clock $clk_io_name [get_ports reset]

set_output_delay 9.0 -clock $clk_io_name [get_ports {Pc[*]}]
set_output_delay 3.5 -clock $clk_io_name [get_ports {ALUResult[*]}]
set_output_delay 0.5 -clock $clk_io_name [get_ports {WriteData[*]}]
set_output_delay 0.5 -clock $clk_io_name [get_ports MemWrite]



