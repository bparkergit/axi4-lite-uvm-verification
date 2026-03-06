class axi_agent extends uvm_agent;
  `uvm_component_utils(axi_agent)
  
  axi_sequencer sqr;
  axi_driver drv;
  axi_monitor mon;
  axi_coverage cov;
  
  uvm_analysis_port #(axi_seq_item) ap;
 
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  
  function new(string name = "axi_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
  
      function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sqr = axi_sequencer::type_id::create("sqr", this);
        if (is_active == UVM_ACTIVE) begin
        	drv = axi_driver::type_id::create("drv", this);
        end
        mon = axi_monitor::type_id::create("mon", this);
        ap = new("ap", this);
        cov  = axi_coverage::type_id::create("coverage", this);
      
    endfunction

      function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
      
         mon.ap.connect(ap);
         mon.ap.connect(cov.analysis_export);

      
    endfunction
  
endclass
