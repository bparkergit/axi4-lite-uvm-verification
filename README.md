# AXI4 Lite slave verifiction environment with UVM

UVM testbench for a 4-deep AXI4 Lite slave interface (32-bit data width).

<img width="2481" height="601" alt="Screenshot 2026-03-06 084212" src="https://github.com/user-attachments/assets/0cef567c-74e9-4599-93f1-802a141cb6ec" />

## Structure
- `rtl/`       : DUT (axi4_lite_slave.sv)
- `tb/`        : UVM components (interface, package, top, tests)
- `sim/`       : Scripts/Makefile for running simulations

## Status
- [X] DUT complete
- [X] Basic UVM env
- [ ] Coverage & scoreboard

Tools: Questa/VCS/EDA Playground

