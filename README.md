# MIPS Processor: RTL to GDS

A single-cycle 32-bit MIPS core, taken from RTL to GDS with OpenROAD-flow-scripts (ORFS)
on SkyWater sky130hd.

Supported instructions: `add`, `sub`, `and`, `or`, `slt`, `lw`, `sw`, `beq`.

## Flow setup

Only the core (`mips`) goes through the flow. Instruction and data memory stay outside
the core, and their timing is modelled as input and output delays in the SDC.

| Setting          | Value |
|------------------|-------|
| Platform         | sky130hd |
| Top module       | `mips` |
| Clock            | 10 ns (100 MHz) |
| Core utilization | 50 % |
| Flow variant     | `nodly`: delay cells are not used |

Run from `OpenROAD-flow-scripts/flow`:

```
export CFG=/home/kakarot/pd/code/mips_processor/orfs/config.mk
make DESIGN_CONFIG=$CFG FLOW_VARIANT=nodly            # RTL to GDS
make DESIGN_CONFIG=$CFG FLOW_VARIANT=nodly gui_final  # view the layout
```

## Constraints

No real memory datasheet, so the memory timings are assumed: 1.5 ns read for both
memories, 0.5 ns write setup. The budget is set by `lw`, the longest instruction:

```
0.0 ->  1.0   PC flop to Pc port                     core
1.0 ->  2.5   instruction memory read                outside
2.5 ->  6.5   Instr -> regfile -> ALU -> ALUResult   core, 4.0 ns
6.5 ->  8.0   data memory read                       outside
8.0 -> 10.0   ReadData -> regfile, incl. setup       core, 2.0 ns
```

This gives the IO delays in `orfs/constraint.sdc`: `Instr` 2.5 ns and `ReadData` 8.0 ns in,
`ALUResult` 3.5 ns, `Pc` 9.0 ns and `WriteData`/`MemWrite` 0.5 ns out.

## Results

| Item             | Value |
|------------------|-------|
| Cells (synthesis) | 4,656, 61,210 µm² |
| Flip-flops       | 1,024 register file + 30 PC |
| Die              | 351.9 x 351.9 µm |
| Final area       | 68,479 µm², 56 % utilization |
| Clock tree       | 109 buffers, skew 0.05 ns |
| Setup            | WNS −0.71 ns, 28 violating endpoints |
| Hold             | 0 violations |
| Routing          | 237 mm wire, 0 router DRC, 0 antenna violations |
| Power            | 13.3 mW |

## Problem fixed: delay cells as port buffers

In the first run, the tool used a delay cell (`clkdlybuf4s50_1`, about 0.5 ns) as the
buffer on several IO ports, including one on the worst path. The `nodly` variant bans
delay cells, which improved setup after CTS:

|           | before   | after (`nodly`) |
|-----------|----------|-----------------|
| Setup WNS | −0.99 ns | −0.56 ns |
| Setup TNS | −15.53 ns | −9.09 ns |

Cost: delay cells are the cheapest way to fix hold. Without them, hold fixes need
ordinary buffers. This design had no hold violations, so the cost was not paid here.

## Open

- Setup is not closed. The worst path `Instr` → `ALUResult` takes 4.71 ns against its 4.0 ns
  budget. Register-to-register paths pass, so the problem is the assumed IO budget.
- KLayout DRC and LVS have not been run.

## Files

```
rtl/               Verilog: core (mips.v), simulation top with memories (mips_top.v)
tb/                Testbenches
orfs/config.mk     ORFS design config
orfs/constraint.sdc  Timing constraints
```

Simulation, from `rtl/`: `iverilog -o ../sim/cpu ../tb/tb_mips.v *.v && vvp ../sim/cpu`
