# MIPS Processor: RTL to GDS

A single-cycle 32-bit MIPS core, taken from RTL to GDS with OpenROAD-flow-scripts (ORFS)
on SkyWater sky130hd.

Supported instructions: `add`, `sub`, `and`, `or`, `slt`, `lw`, `sw`, `beq`.

## Flow setup

Only the core (`mips`) goes through the flow. Instruction and data memory stay outside
the core, and their timing is modelled as input and output delays in the SDC.

The current setup is `orfs_run2/`, variant `bud10vclk`:

| Setting          | Value |
|------------------|-------|
| Platform         | sky130hd |
| Top module       | `mips` |
| Clock            | 10 ns (100 MHz) |
| Core utilization | 50 % |
| Port buffers     | `sky130_fd_sc_hd__buf_1` (`BUFFER_PORTS_ARGS`) |
| SDC              | `orfs_run2/constraint_bud10_vclk.sdc` |

Run from `OpenROAD-flow-scripts/flow`:

```
export CFG=/home/kakarot/pd/code/mips_processor/orfs_run2/config.mk
make DESIGN_CONFIG=$CFG FLOW_VARIANT=bud10vclk            # RTL to GDS
make DESIGN_CONFIG=$CFG FLOW_VARIANT=bud10vclk drc        # KLayout DRC
make DESIGN_CONFIG=$CFG FLOW_VARIANT=bud10vclk gui_final  # view the layout
```

STA at another corner: set `LIB` in `orfs_run2/sta_corner.tcl`, then run it with `openroad`.

## Constraints

No real memory datasheet, so the memory timings are assumed: 1.5 ns read for both
memories, 0.5 ns write setup. The budget is set by `lw`, the longest instruction:

```
0.0 ->  1.0   PC flop to Pc port                     core
1.0 ->  2.5   instruction memory read                outside
2.5 ->  7.5   Instr -> regfile -> ALU -> ALUResult   core, 5.0 ns
7.5 ->  9.0   data memory read                       outside
9.0 -> 10.0   ReadData -> regfile, incl. setup       core, 1.0 ns
```

IO delays: `Instr` 2.5 ns and `ReadData` 9.0 ns in, `ALUResult` 2.5 ns, `Pc` 9.0 ns and
`WriteData`/`MemWrite` 0.5 ns out.

The IO delays use a virtual clock `vclk`, the clock seen by the memories. It has a 0.77 ns
source latency, the clock tree latency measured after CTS, so the memories' clock arrives
as late as the core's.

## Results

`bud10vclk`, tt corner:

| Item             | Value |
|------------------|-------|
| Cells (synthesis) | 4,656, 61,207 µm² |
| Flip-flops       | 1,024 register file + 30 PC |
| Die              | 351.9 x 351.9 µm |
| Final area       | 72,127 µm², 59 % utilization |
| Clock tree       | 111 buffers, skew 0.05 ns |
| Setup            | WNS −0.04 ns, TNS −1.88 ns, 125 violating endpoints |
| Hold             | 0 violations |
| Register to register | minimum period 6.89 ns (145 MHz) |
| Routing          | 226 mm wire, 44,087 vias |
| Power            | 12.9 mW |

## Checks

| Check            | Result |
|------------------|--------|
| Router DRC       | 0 |
| Antenna          | 0 |
| KLayout DRC      | 7, all rule `li.5`, inside standard cells (`clkbuf_4`, `edfxtp_1`, ...), not in the routing |
| LVS              | not completed: KLayout cannot read the `conb_1` tie cell in the CDL netlist (resistor value `short`) |
| Hold at ff (`ff_n40C_1v95`) | met, worst slack +0.39 ns |
| Setup at ss      | not run yet |

## Timing closure

Worst setup slack after CTS, tt corner, one change at a time:

| Variant     | Port buffers | Core budget, Instr→ALUResult / ReadData→regfile | IO clock | WNS | TNS |
|-------------|--------------|-------------------|-----------------------|----------|-----------|
| `portbuf`   | `buf_1`      | 4.0 / 2.0 ns      | `core_clock`, no latency | −0.55 ns | −15.07 ns |
| `bud10`     | tool default | 5.0 / 1.0 ns      | `core_clock`, no latency | −0.24 ns | −5.72 ns |
| `bud10vclk` | `buf_1`      | 5.0 / 1.0 ns      | `vclk`, 0.77 ns latency  | 0.00 ns  | 0.00 ns |

1. **Port buffers.** In the first run (`orfs/`), the tool used a delay cell
   (`clkdlybuf4s50_1`, about 0.5 ns) as the buffer on several IO ports, including one on the
   worst path. The fix there was to ban delay cells for the whole flow (`nodly`), at the cost
   of losing them for hold repair. Run 2 sets only the port buffer cell to `buf_1`, so delay
   cells stay available for hold.
2. **Budget.** `Instr` → `ALUResult` took 4.55 ns against its 4.0 ns budget. 1.0 ns moved
   from the `ReadData` side to the `ALUResult` side.
3. **Virtual clock.** The IO delays now refer to a clock with the same latency as the
   core's clock tree.

## Open

- Setup misses by 0.04 ns after routing. The worst path is `ReadData` → register file, while
  `Instr` → `ALUResult` has +0.10 ns, so the budget split can still be tuned.
- LVS does not complete.
- Setup at the ss corner has not been run.

## Files

```
rtl/                 Verilog: core (mips.v), simulation top with memories (mips_top.v)
tb/                  Testbenches
orfs/                Run 1: first config and SDC (nodly variant)
orfs_run2/           Run 2: config, SDC variants, corner STA script and logs
```

Simulation, from `rtl/`: `iverilog -o ../sim/cpu ../tb/tb_mips.v *.v && vvp ../sim/cpu`
