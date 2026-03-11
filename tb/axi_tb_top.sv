`timescale 1ns / 1ps

// ───────────────────────────────────────────────
//   UVM imports and macros — MUST come first!
// ───────────────────────────────────────────────
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "axi_seq_item.sv"
`include "axi_if.sv"
`include "axi_driver.sv"
`include "axi_sequencer.sv"
`include "axi_monitor.sv"
`include "axi_coverage.sv"
`include "axi_agent.sv"
`include "axi_scoreboard.sv"
`include "axi_env.sv"
`include "axi_base_sequence.sv"
`include "axi_base_test.sv"



module axi_tb_top; 
    parameter int ADDR_WIDTH = 32;
    parameter int DATA_WIDTH = 32;

    logic aclk = 0;
    logic aresetn = 0;

    always #5 aclk = ~aclk;
  
  
  axi_if #(
    .ADDR_WIDTH(ADDR_WIDTH), 
    .DATA_WIDTH(DATA_WIDTH)
     ) axi_if_inst (
    .aclk(aclk), 
    .aresetn(aresetn)
    );

axi4_lite_slave dut(
    .axi(axi_if_inst)
);

      // Reset generation
    initial begin
        aresetn = 0;
        #10;
        aresetn = 1;
    end

    // UVM + waveform dump
    initial begin
        // Set interface for driver
      uvm_config_db #(virtual axi_if.DRIVER)::set(
            null,
            "uvm_test_top.env.agent.drv",
            "vif",
            axi_if_inst
        );
      uvm_config_db #(virtual axi_if.MONITOR)::set(
            null,
            "uvm_test_top.env.agent.mon",
            "vif",
            axi_if_inst
        );

      // set interface for scoreboard
      uvm_config_db #(virtual axi_if)::set(
            null,
            "uvm_test_top.env.scoreboard",
            "vif",
            axi_if_inst
        );

      run_test("axi_base_test");
    end
  
      // Use WLF format (recommended for Questa/ModelSim)
    initial begin
      $wlfdumpvars(0, axi_tb_top);   // dumps everything
        // If you prefer VCD:
      $dumpfile("axi_uvm.vcd");
      $dumpvars(0, axi_tb_top);
    end
  
endmodule
