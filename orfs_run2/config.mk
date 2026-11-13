export PLATFORM = sky130hd
export DESIGN_NAME = mips
export DESIGN_NICKNAME = mips_run2
export VERILOG_FILES =	/home/kakarot/pd/code/mips_processor/rtl/adder.v \
						/home/kakarot/pd/code/mips_processor/rtl/alu.v \
						/home/kakarot/pd/code/mips_processor/rtl/control_unit.v \
						/home/kakarot/pd/code/mips_processor/rtl/mips.v \
						/home/kakarot/pd/code/mips_processor/rtl/mux2.v \
						/home/kakarot/pd/code/mips_processor/rtl/pc_register.v \
						/home/kakarot/pd/code/mips_processor/rtl/register.v \
						/home/kakarot/pd/code/mips_processor/rtl/sign_extend.v
export SDC_FILE = /home/kakarot/pd/code/mips_processor/orfs_run2/constraint.sdc
export CORE_UTILIZATION = 50

ifeq ($(FLOW_VARIANT),portbuf)
export BUFFER_PORTS_ARGS = -buffer_cell sky130_fd_sc_hd__buf_1
endif

ifeq ($(FLOW_VARIANT),bud10)
export SDC_FILE = /home/kakarot/pd/code/mips_processor/orfs_run2/constraint_bud10.sdc
endif

ifeq ($(FLOW_VARIANT),bud10vclk)
export SDC_FILE = /home/kakarot/pd/code/mips_processor/orfs_run2/constraint_bud10_vclk.sdc
export BUFFER_PORTS_ARGS = -buffer_cell sky130_fd_sc_hd__buf_1
endif