
# AXI4-Lite slave verifiction environment with UVM

UVM testbench for a 4-entry AXI4 Lite slave interface (32-bit data width).
![559442293-b82fbde3-57db-42ea-ac36-25c75682d5a5](https://github.com/user-attachments/assets/021c31a4-7e40-4e55-b02b-6c8bab64ed52)

<img width="2481" height="601" alt="Screenshot 2026-03-06 084212" src="https://github.com/user-attachments/assets/0cef567c-74e9-4599-93f1-802a141cb6ec" />

<img width="843" height="126" alt="Screenshot 2026-04-10 210618" src="https://github.com/user-attachments/assets/db2408f7-831c-4816-aed6-7e0e3bdaaa13" />

## Structure
- `rtl/`       : DUT (axi4_lite_slave.sv)
- `tb/`        : UVM components (interface, package, top, tests)
- `sim/`       : Scripts/Makefile for running simulations

## Verification Plan
1️⃣ Basic Write & Read Functionality

Write operations:
- [x] Send AW + W to an address.
- [x] Check BVALID/BREADY handshake occurs.
- [x] Verify the register file actually contains the written value.

Read operations:
- [x] Send AR to an address.
- [x] Check RVALID/RREADY handshake occurs.
- [x] Verify read data matches expected register content.

Corner cases:
- [ ] Write then immediately read the same address.
- [ ] Read before write to ensure reset values are correct.

2️⃣ AXI4-Lite Protocol Rules

Handshake rules:
- [ ] AWREADY must only assert when the slave is ready.
- [ ] WREADY must only assert when the slave can accept data.
- [ ] BVALID must be generated only after AW and W have both been captured.
- [ ] ARREADY must assert only when slave can accept read address.
- [ ] RVALID must be valid after AR has been accepted.

Single-cycle handshakes:
- [x] Test that AW/W/AR/R handshakes can occur on same cycle or different cycles.

3️⃣ Out-of-Order / Backpressure Scenarios
- [x] Write AW arrives before W
- [x] Write W arrives before AW
- [x] AW and W arrive together
- [x] BVALID only asserted once both AW + W received.
- [x] Read AR arrives while write in progress
- [x] Verify read does not overwrite write data or return stale data.

4️⃣ Reset Behavior

Assert aresetn at different times:
- [ ] While a write is in progress.
- [ ] While a read is in progress.

Verify:
- [ ] Registers reset to default value (usually 0).
- [ ] AXI handshake signals return to idle state.

5️⃣ Multiple Registers / Address Decoding

regfile[0:3]

  Verify:
- [x] Writes go to correct addresses (mask using ADDR[3:2]).
- [x] Reads return the correct data for the requested address.
- [ ] Out-of-range addresses are either ignored or generate 2'b10 (SLVERR) if you implement it.

6️⃣ Protocol Assertions / Coverage

Assertions in interface:
- [x] AWVALID |-> ##[0:16] AWREADY
- [x] WVALID |-> ##[0:16] WREADY
- [x] ARVALID |-> ##[0:16] ARREADY
- [x] RVALID |-> ##[0:16] RREADY

Functional coverage:
- [x] All addresses written at least once.
- [x] All registers read at least once.
- [x] All handshake scenarios (AW→W, W→AW, same-cycle) covered.
- [ ] Reset sequences tested.

7️⃣ Optional Advanced Checks
- [x] Simultaneous read/write
- [ ] Invalid signal assertion (e.g., AWVALID=1 with WVALID=0)


## Status
- [X] DUT complete
- [X] Basic UVM env
- [ ] Coverage & scoreboard

Tools: Questa/VCS/EDA Playground

