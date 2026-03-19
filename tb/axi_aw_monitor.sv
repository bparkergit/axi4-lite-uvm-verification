class axi_aw_monitor extends uvm_monitor;
    `uvm_component_utils(axi_aw_monitor)

    uvm_analysis_port #(axi_seq_item) ap;

    virtual axi_if.MONITOR vif;

    function new(string name = "axi_aw_monitor", uvm_component parent);
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
      logic [31:0] awaddr;
      logic [2:0] awprot;

      
        forever begin
            @(vif.cb_mon);  // sample every clock

          	txn = null;
          
            // Write Address handshake
            if (vif.cb_mon.s_axi_awvalid && vif.cb_mon.s_axi_awready) begin 
                awaddr  = vif.cb_mon.s_axi_awaddr;
                awprot  = vif.cb_mon.s_axi_awprot;

                txn = axi_seq_item::type_id::create("txn"); 
                txn.s_axi_awaddr = awaddr;
                txn.s_axi_awprot = awprot;
                txn.is_write = 1'b1;
                ap.write(txn);

             end

        end
    endtask
endclass
