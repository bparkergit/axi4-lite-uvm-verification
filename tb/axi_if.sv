interface axi_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic aclk,
    input logic aresetn
);

logic [31:0] s_axi_awaddr;
logic [2:0]  s_axi_awprot;
logic        s_axi_awvalid;
logic        s_axi_awready;

logic [31:0] s_axi_wdata;
logic [3:0]  s_axi_wstrb;
logic        s_axi_wvalid;
logic        s_axi_wready;

logic [1:0]  s_axi_bresp;
logic        s_axi_bvalid;
logic        s_axi_bready;

logic [31:0] s_axi_araddr;
logic [2:0]  s_axi_arprot;
logic        s_axi_arvalid;
logic        s_axi_arready;

logic [31:0] s_axi_rdata;
logic [1:0]  s_axi_rresp;
logic        s_axi_rvalid;
logic        s_axi_rready;


  
  
  clocking cb_drv @(posedge aclk);
    // Write Address Channel
    output s_axi_awaddr;
    output s_axi_awprot;
    output s_axi_awvalid;
    input s_axi_awready;

    // Write Data Channel
    output s_axi_wdata;
    output s_axi_wstrb;
    output s_axi_wvalid;
    input s_axi_wready;

    // Write Response Channel
    input s_axi_bresp;
    input s_axi_bvalid;
    output s_axi_bready;

    // Read Address Channel
    output s_axi_araddr;
    output s_axi_arprot;
    output s_axi_arvalid;
    input s_axi_arready;

    // Read Data Channel
    input s_axi_rdata;
    input s_axi_rresp;
    input s_axi_rvalid;
    output s_axi_rready;
    endclocking

  
  clocking cb_mon @(posedge aclk);
    // Write Address Channel
    input s_axi_awaddr;
    input s_axi_awprot;
    input s_axi_awvalid;
    input s_axi_awready;

    // Write Data Channel
    input s_axi_wdata;
    input s_axi_wstrb;
    input s_axi_wvalid;
    input s_axi_wready;

    // Write Response Channel
    input s_axi_bresp;
    input s_axi_bvalid;
    input s_axi_bready;

    // Read Address Channel
    input s_axi_araddr;
    input s_axi_arprot;
    input s_axi_arvalid;
    input s_axi_arready;

    // Read Data Channel
    input s_axi_rdata;
    input s_axi_rresp;
    input s_axi_rvalid;
    input s_axi_rready;
    endclocking
  
      modport DUT (
        input  aclk, aresetn,

        input  s_axi_awaddr, s_axi_awprot, s_axi_awvalid,
        output s_axi_awready,

        input  s_axi_wdata, s_axi_wstrb, s_axi_wvalid,
        output s_axi_wready,

        output s_axi_bresp, s_axi_bvalid,
        input  s_axi_bready,

        input  s_axi_araddr, s_axi_arprot, s_axi_arvalid,
        output s_axi_arready,

        output s_axi_rdata, s_axi_rresp, s_axi_rvalid,
        input  s_axi_rready
    );

    modport DRIVER (
        clocking cb_drv,
        input aresetn
    );

    modport MONITOR (
        clocking cb_mon,
        input aresetn
    );
     
    // ───────────────────────────────────────────────
    // Basic protocol assertion
    // ───────────────────────────────────────────────
    
       assert property (@(posedge aclk) disable iff (!aresetn)
                        s_axi_awvalid |-> ##[0:16] s_axi_awready); 

     
       assert property (@(posedge aclk) disable iff (!aresetn)
                        s_axi_wvalid |-> ##[0:16] s_axi_wready); 

    
       assert property (@(posedge aclk) disable iff (!aresetn)
                        s_axi_arvalid |-> ##[0:16] s_axi_arready);
         
         
       assert property (@(posedge aclk) disable iff (!aresetn)                
                        s_axi_rvalid |-> ##[0:16] s_axi_rready); 
                
         
       assert property (@(posedge aclk) disable iff (!aresetn)                
                        s_axi_bvalid |-> ##[0:16] s_axi_bready); 
                  
               
        
         sequence aw_hs;
           s_axi_awvalid && s_axi_awready;
         endsequence

        
         sequence w_hs;
           s_axi_wvalid && s_axi_wready;
         endsequence

       
         property p_write_resp;
          @(posedge aclk) disable iff (!aresetn)
           (aw_hs ##[0:$] w_hs or w_hs ##[0:$] aw_hs) |-> ##[0:$] s_axi_bvalid;
         endproperty
         
         
         assert property(p_write_resp);
                
endinterface
