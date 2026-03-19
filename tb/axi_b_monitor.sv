class axi_b_monitor extends uvm_monitor;
    `uvm_component_utils(axi_b_monitor)

    uvm_analysis_port #(axi_seq_item) ap;


    virtual axi_if.MONITOR vif;

    function new(string name = "axi_b_monitor", uvm_component parent);
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
                    
            
            // Write Response handshake
            if (vif.cb_mon.s_axi_bvalid && vif.cb_mon.s_axi_bready)begin
                txn.is_write = 1'b1;
                ap.write(txn);
        
            end

        end
    endtask
endclass
