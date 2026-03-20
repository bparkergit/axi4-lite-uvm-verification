class axi_w_monitor extends uvm_monitor;
    `uvm_component_utils(axi_w_monitor)

    uvm_analysis_port #(axi_seq_item) ap;


    virtual axi_if.MONITOR vif;

  function new(string name = "axi_w_monitor", uvm_component parent);
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
 
      logic [31:0] wdata;
      logic [3:0] wstrb;
      
      
      
        forever begin
            @(vif.cb_mon);  // sample every clock

          	txn = null;
          

            // Write Data handshake
            if (vif.cb_mon.s_axi_wvalid && vif.cb_mon.s_axi_wready) begin
                wdata   = vif.cb_mon.s_axi_wdata;
                wstrb   = vif.cb_mon.s_axi_wstrb;

             txn = axi_seq_item::type_id::create("txn"); 
             txn.s_axi_wdata = wdata;
             txn.s_axi_wstrb = wstrb;
             txn.s_axi_wvalid  = vif.cb_mon.s_axi_wvalid;
             txn.s_axi_wready  = vif.cb_mon.s_axi_wready;
             txn.w_seen = 1'b1;
             txn.is_write = 1'b1;
           
             $display("%d: w monitor sending data=0x%08h wstrb=%b", $time, wdata, wstrb);
              
            ap.write(txn);

          end


        end
    endtask
endclass
