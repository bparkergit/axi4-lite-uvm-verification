class axi_ar_monitor extends uvm_monitor;
    `uvm_component_utils(axi_ar_monitor)

    uvm_analysis_port #(axi_seq_item) ap;


    virtual axi_if.MONITOR vif;

    function new(string name = "axi_ar_monitor", uvm_component parent);
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

      logic [31:0] araddr;
      logic [2:0] arprot;
      
        forever begin
            @(vif.cb_mon);  // sample every clock

          	txn = null;

            // Read Address handshake
            if (vif.cb_mon.s_axi_arvalid && vif.cb_mon.s_axi_arready) begin
                txn = axi_seq_item::type_id::create("txn"); 
                araddr  = vif.cb_mon.s_axi_araddr;
                arprot  = vif.cb_mon.s_axi_arprot; 
                txn.s_axi_araddr = araddr;
                txn.s_axi_arprot = arprot;   
                txn.s_axi_arvalid = 1'b1;
              	txn.s_axi_arready = 1'b1;
                ap.write(txn);    
            end


        end
    endtask
endclass
