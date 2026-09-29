# MIPS Processor

A single-cycle 32-bit MIPS processor. Every instruction completes in one clock cycle.

## Design

- 32 x 32-bit register file, `$0` always reads 0, synchronous reset clears every register
- Instruction memory: 64 words, loaded from `program.hex`
- Data memory: 32 words, loaded from `data.hex`, write on the rising clock edge, asynchronous read
- Both memories are word-addressed: the low 2 address bits are ignored
- Control unit is split into a main decoder (from `opcode`) and an ALU decoder (from `funct`)

Supported instructions:

| Instruction | Type | Opcode   | Funct    | ALU op |
|-------------|------|----------|----------|--------|
| `add`       | R    | `000000` | `100000` | `010`  |
| `sub`       | R    | `000000` | `100010` | `110`  |
| `and`       | R    | `000000` | `100100` | `000`  |
| `or`        | R    | `000000` | `100101` | `001`  |
| `slt`       | R    | `000000` | `101010` | `111`  |
| `lw`        | I    | `100011` | -        | `010`  |
| `sw`        | I    | `101011` | -        | `010`  |
| `beq`       | I    | `000100` | -        | `110`  |

The ALU also implements `sltu` (op `101`), but the decoder does not generate it yet.

## Test program

`rtl/data.hex` starts data memory with word 0 = 10 and word 1 = 20. `rtl/program.hex`:

```
addr  hex       instruction
0x00  8C080000  lw  $t0, 0($zero)      # $t0 = 10
0x04  8C090004  lw  $t1, 4($zero)      # $t1 = 20
0x08  01095420  add $t2, $t0, $t1      # $t2 = 30
0x0C  AC0A0008  sw  $t2, 8($zero)      # mem[2] = 30
0x10  114AFFFB  beq $t2, $t2, -5       # always taken, jumps back to 0x00
```

## Run

Unit tests, run from `sim/`:

```
mkdir -p sim && cd sim
iverilog -o alu      ../tb/tb_alu.v      ../rtl/alu.v          && vvp alu
iverilog -o register ../tb/tb_register.v ../rtl/register.v     && vvp register
iverilog -o cu       tb_control_unit.v   ../rtl/control_unit.v && vvp cu
```

Full CPU test, run from `rtl/`, because `$readmemh` loads `program.hex` and `data.hex` from the current directory:

```
cd rtl
iverilog -o ../sim/cpu ../tb/tb_mips.v *.v
vvp ../sim/cpu
```

iverilog warns that the hex files have fewer words than the memories. This is expected, and the unused words stay `x`.

To view the waveforms: `gtkwave sim/mips.vcd` (or `alu.vcd`, `register.vcd`, `control_unit.vcd`).

## Tests

- `tb_alu`: 10 checks covering add, sub, and, or, slt, sltu and the `zero` flag
- `tb_register`: reset clears registers, write then read on both ports, writes to `$0` are ignored, no write when `write_enable = 0`
- `tb_control_unit`: control signals and `ALUControl` for each supported instruction, plus an unknown opcode
- `tb_mips`: runs the test program for 5 cycles, then checks `$t2 = 30`, `mem[2] = 30`, and that the `beq` jumped the PC back to 0

## Files

```
rtl/mips.v                 Top level, connects the datapath
rtl/pc_register.v          Program counter
rtl/adder.v                32-bit adder (PC + 4, branch target)
rtl/instruction_memory.v   Instruction memory, loads program.hex
rtl/control_unit.v         Main decoder + ALU decoder
rtl/register.v             Register file
rtl/sign_extend.v          16 to 32-bit sign extension
rtl/mux2.v                 2:1 mux, parameterized width
rtl/alu.v                  ALU
rtl/data_memory.v          Data memory, loads data.hex
rtl/program.hex            Test program
rtl/data.hex               Initial data memory
tb/tb_alu.v                ALU testbench
tb/tb_register.v           Register file testbench
tb/tb_mips.v               Full CPU testbench
tb/tb_control_unit.v       Control unit testbench
```
