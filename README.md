# AXI4 Lite slave verifiction environment with UVM

UVM testbench for a 4-deep AXI4 Lite slave interface (32-bit data width).

## Structure
- `rtl/`       : DUT (axi4_lite_slave.sv)
- `tb/`        : UVM components (interface, package, top, tests)
- `sim/`       : Scripts/Makefile for running simulations

## Status
- [X] DUT complete
- [X] Basic UVM env
- [ ] Coverage & scoreboard

Tools: Questa/VCS/EDA Playground
