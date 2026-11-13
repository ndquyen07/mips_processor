# Real clock of the core, enters at port clk
create_clock -name core_clock -period 10 [get_ports clk]
# Estimated tree latency, used only while the clock is ideal (before CTS).
# After CTS, set_propagated_clock replaces it with the real tree latency.
set_clock_latency 0.77 [get_clocks core_clock]

# Virtual clock: the clock seen by imem/dmem. Not attached to any port.
create_clock -name vclk -period 10
# The outside clock also arrives 0.77 ns late (value from portbuf CTS).
set_clock_latency -source 0.77 [get_clocks vclk]

set_output_delay 9.0 -clock vclk [get_ports {Pc[*]}]
set_input_delay  2.5 -clock vclk [get_ports {Instr[*]}]
# bud10: 10 - (2.5 + 5.0)
set_output_delay 2.5 -clock vclk [get_ports {ALUResult[*]}]
set_output_delay 0.5 -clock vclk [get_ports {WriteData[*]}]
set_output_delay 0.5 -clock vclk [get_ports MemWrite]
# bud10: 1.0 ns moved from here to ALUResult
set_input_delay  9.0 -clock vclk [get_ports {ReadData[*]}]
set_input_delay  1.0 -clock vclk [get_ports reset]