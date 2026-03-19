class axi_r_monitor extends uvm_monitor;
    `uvm_component_utils(axi_r_monitor)

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

        forever begin
            @(vif.cb_mon);  // sample every clock

          	txn = null;

            // Read Data handshake 
            if (vif.cb_mon.s_axi_rvalid && vif.cb_mon.s_axi_rready) begin
              	txn = axi_seq_item::type_id::create("txn");
                txn.s_axi_rdata   = vif.cb_mon.s_axi_rdata;
                txn.s_axi_rresp   = vif.cb_mon.s_axi_rresp;
     
              	txn.s_axi_rvalid = 1'b1;
              	txn.s_axi_rready = 1'b1;
				txn.is_write = 1'b0;
                ap.write(txn);
              
            end
        end
    endtask
endclass
