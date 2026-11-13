export PLATFORM = sky130hd
export VERILOG_FILES =	/home/kakarot/pd/code/mips_processor/rtl/adder.v \
						/home/kakarot/pd/code/mips_processor/rtl/alu.v \
						/home/kakarot/pd/code/mips_processor/rtl/control_unit.v \
						/home/kakarot/pd/code/mips_processor/rtl/mips.v \
						/home/kakarot/pd/code/mips_processor/rtl/mux2.v \
						/home/kakarot/pd/code/mips_processor/rtl/pc_register.v \
						/home/kakarot/pd/code/mips_processor/rtl/register.v \
						/home/kakarot/pd/code/mips_processor/rtl/sign_extend.v
export DESIGN_NAME = mips
export DESIGN_NICKNAME = mips_flow
export SDC_FILE = /home/kakarot/pd/code/mips_processor/orfs/constraint.sdc
export CORE_UTILIZATION = 50

ifeq ($(FLOW_VARIANT),nodly)
export DONT_USE_CELLS += sky130_fd_sc_hd__clkdlybuf4s* sky130_fd_sc_hd__dlygate4sd* sky130_fd_sc_hd__dlymetal6s*
endif