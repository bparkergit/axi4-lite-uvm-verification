class axi_monitor extends uvm_monitor;
    `uvm_component_utils(axi_monitor)

    uvm_analysis_port #(axi_seq_item) ap;

    virtual axi_if.MONITOR vif;

    function new(string name = "axi_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);

        if (!uvm_config_db#(virtual axi_if.MONITOR)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not set")
    endfunction

    task run_phase(uvm_phase phase);
      axi_seq_item txn;
      bit aw_seen = 1'b0;
      bit w_seen = 1'b0;
      logic [31:0] awaddr,araddr;
      logic [2:0] awprot,arprot;
      logic [31:0] wdata;
      logic [3:0] wstrb;
 
        forever begin
            @(vif.cb_mon);  // sample every clock

          	txn = null;
          
            // Write Address handshake
            if (vif.cb_mon.s_axi_awvalid && vif.cb_mon.s_axi_awready) begin 
                awaddr  = vif.cb_mon.s_axi_awaddr;
                awprot  = vif.cb_mon.s_axi_awprot;
                aw_seen = 1'b1;
            end

            // Write Data handshake
            if (vif.cb_mon.s_axi_wvalid && vif.cb_mon.s_axi_wready) begin
                wdata   = vif.cb_mon.s_axi_wdata;
                wstrb   = vif.cb_mon.s_axi_wstrb;
                w_seen = 1'b1;
            end

          if(w_seen && aw_seen) begin
             txn = axi_seq_item::type_id::create("txn"); 
             txn.s_axi_awaddr = awaddr;
             txn.s_axi_awprot = awprot;
             txn.s_axi_wdata = wdata;
             txn.s_axi_wstrb = wstrb;
             txn.s_axi_wvalid  = 1'b1;
            
          
            // Write Response handshake
            if (vif.cb_mon.s_axi_bvalid && vif.cb_mon.s_axi_bready) begin
                ap.write(txn);
              
              @(vif.cb_mon);

              w_seen = 1'b0;
              aw_seen = 1'b0;
            end
          end

            // Read Address handshake
            if (vif.cb_mon.s_axi_arvalid && vif.cb_mon.s_axi_arready) begin
                araddr  = vif.cb_mon.s_axi_araddr;
                arprot  = vif.cb_mon.s_axi_arprot;        
            end

            // Read Data handshake 
            if (vif.cb_mon.s_axi_rvalid && vif.cb_mon.s_axi_rready) begin
              	txn = axi_seq_item::type_id::create("txn");
                txn.s_axi_rdata   = vif.cb_mon.s_axi_rdata;
                txn.s_axi_rresp   = vif.cb_mon.s_axi_rresp;
     
                txn.s_axi_araddr = araddr;
                txn.s_axi_arprot = arprot;
              
                ap.write(txn);
            end
        end
    endtask
endclass
