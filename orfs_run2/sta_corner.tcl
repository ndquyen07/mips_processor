# Liberty file of the corner to analyze. Change only this line for other corners.
set LIB /home/kakarot/.ciel/ciel/sky130/versions/1689ac3f2dc763876eaf967227c7dfe831b031ae/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__ff_n40C_1v95.lib

# Results of the bud10vclk run
set RES /home/kakarot/OpenROAD-flow-scripts/flow/results/sky130hd/mips_run2/bud10vclk

# Same order as open.tcl in ORFS
read_liberty $LIB
read_db $RES/6_final.odb
read_sdc $RES/6_final.sdc
source /home/kakarot/OpenROAD-flow-scripts/flow/platforms/sky130hd/setRC.tcl
read_spef $RES/6_final.spef

# The layout has a real clock tree
set_propagated_clock [all_clocks]

# Setup
report_wns
report_tns
report_clock_min_period
report_checks -path_delay max

# Hold
report_worst_slack -min
report_checks -path_delay min