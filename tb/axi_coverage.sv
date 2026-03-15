class axi_coverage extends uvm_subscriber #(axi_seq_item) ;
  
  `uvm_component_utils(axi_coverage)
  
    covergroup cg_transaction with function sample(
    // Write Address Channel
    bit   [32-1:0]    s_axi_awaddr,
    bit   [2:0]               s_axi_awprot,
    bit                       s_axi_awvalid,
    bit                      s_axi_awready,

    // Write Data Channel
    bit   [32-1:0]    s_axi_wdata,
    bit   [32/8-1:0]  s_axi_wstrb,
    bit                       s_axi_wvalid,
    bit                      s_axi_wready,

    // Write Response Channel
    bit  [1:0]               s_axi_bresp,
    bit                      s_axi_bvalid,
    bit                       s_axi_bready,

    // Read Address Channel
    bit   [32-1:0]    s_axi_araddr,
    bit   [2:0]               s_axi_arprot,
    bit                       s_axi_arvalid,
    bit                      s_axi_arready,

    // Read Data Channel
    bit  [32-1:0]    s_axi_rdata,
    bit  [1:0]               s_axi_rresp,
    bit                      s_axi_rvalid,
    bit                       s_axi_rready
  );
      
    coverpoint s_axi_awvalid {
          bins low   = {0};
          bins high  = {1};
        }

    coverpoint s_axi_wvalid {
          bins low  = {0};
          bins high  = {1};
        }
        


      // Cover the cases where AW happens before W and W happens before AW
      
    cross s_axi_awvalid, s_axi_wvalid;
      
      
    endgroup
       
   function new(string name="fifo_coverage", uvm_component parent);
          super.new(name, parent);
          cg_transaction = new();
          cg_transaction.set_inst_name("cg_transaction");  // helps reporting
    endfunction
  
    // This is called automatically via analysis_export
    virtual function void write(axi_seq_item t);
    // debug
      `uvm_info("COV_SAMPLE", $sformatf("Sampling txn: s_axi_wvalid=%0b s_axi_arready=%0b",t.s_axi_wvalid, t.s_axi_arready), UVM_MEDIUM)
   
    // Pass relevant fields to the covergroup's sample function
    cg_transaction.sample(
    // Write Address Channel
    .s_axi_awaddr(t.s_axi_awaddr),
    .s_axi_awprot(t.s_axi_awprot),
    .s_axi_awvalid(t.s_axi_awvalid),
    .s_axi_awready(t.s_axi_awready),

    // Write Data Channel
    .s_axi_wdata(t.s_axi_wdata),
    .s_axi_wstrb(t.s_axi_wstrb),
    .s_axi_wvalid(t.s_axi_wvalid),
    .s_axi_wready(t.s_axi_wready),

    // Write Response Channel
    .s_axi_bresp(t.s_axi_bresp),
    .s_axi_bvalid(t.s_axi_bvalid),
    .s_axi_bready(t.s_axi_bready),

    // Read Address Channel
    .s_axi_araddr(t.s_axi_araddr),
    .s_axi_arprot(t.s_axi_arprot),
    .s_axi_arvalid(t.s_axi_arvalid),
    .s_axi_arready(t.s_axi_arready),

    // Read Data Channel
    .s_axi_rdata(t.s_axi_rdata),
    .s_axi_rresp(t.s_axi_rresp),
    .s_axi_rvalid(t.s_axi_rvalid),
    .s_axi_rready(t.s_axi_rready)
    );
  endfunction
  
endclass
