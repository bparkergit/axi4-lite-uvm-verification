`timescale 1ns / 1ps

// ───────────────────────────────────────────────
//   UVM imports and macros — MUST come first!
// ───────────────────────────────────────────────
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "axi_seq_item.sv"
`include "axi_if.sv"
`include "axi_wdriver.sv"
`include "axi_rdriver.sv"
`include "axi_sequencer.sv"
`include "axi_monitor.sv"
`include "axi_coverage.sv"
`include "axi_virtual_sequencer.sv"
`include "axi_agent.sv"
`include "axi_scoreboard.sv"
`include "axi_env.sv"
`include "axi_read_sequence.sv"
`include "axi_write_sequence.sv"
`include "wr_rd_vseq.sv"
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

axi4_lite_slave #(
    .ADDR_WIDTH(ADDR_WIDTH), 
    .DATA_WIDTH(DATA_WIDTH)
     ) dut (
  .aclk(aclk),
  .aresetn(aresetn),

    .s_axi_awaddr (axi_if_inst.s_axi_awaddr),
    .s_axi_awprot (axi_if_inst.s_axi_awprot),
    .s_axi_awvalid(axi_if_inst.s_axi_awvalid),
    .s_axi_awready(axi_if_inst.s_axi_awready),

    .s_axi_wdata  (axi_if_inst.s_axi_wdata),
    .s_axi_wstrb  (axi_if_inst.s_axi_wstrb),
    .s_axi_wvalid (axi_if_inst.s_axi_wvalid),
    .s_axi_wready (axi_if_inst.s_axi_wready),

    .s_axi_bresp  (axi_if_inst.s_axi_bresp),
    .s_axi_bvalid (axi_if_inst.s_axi_bvalid),
    .s_axi_bready (axi_if_inst.s_axi_bready),

    .s_axi_araddr (axi_if_inst.s_axi_araddr),
    .s_axi_arprot (axi_if_inst.s_axi_arprot),
    .s_axi_arvalid(axi_if_inst.s_axi_arvalid),
    .s_axi_arready(axi_if_inst.s_axi_arready),

    .s_axi_rdata  (axi_if_inst.s_axi_rdata),
    .s_axi_rresp  (axi_if_inst.s_axi_rresp),
    .s_axi_rvalid (axi_if_inst.s_axi_rvalid),
    .s_axi_rready (axi_if_inst.s_axi_rready)
);

      // Reset generation
    initial begin
        aresetn = 1;
        #5;
        aresetn = 0;
        #10;
        aresetn = 1;
    end

    // UVM + waveform dump
    initial begin
        // Set interface for driver
      uvm_config_db #(virtual axi_if.DRIVER)::set(
            null,
            "uvm_test_top.env.agent.*",
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
