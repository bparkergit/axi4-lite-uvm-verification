class axi_agent extends uvm_agent;
  `uvm_component_utils(axi_agent)
  
  axi_sequencer wsqr;
  axi_sequencer rsqr;
  axi_wdriver wdrv;
  axi_rdriver rdrv;
  axi_monitor mon;
  axi_coverage cov;
  axi_virtual_sequencer vseqr;
  
  uvm_analysis_port #(axi_seq_item) ap;
 
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  
  function new(string name = "axi_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
  
      function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (is_active == UVM_ACTIVE) begin
          wsqr = axi_sequencer::type_id::create("wsqr", this);
          rsqr = axi_sequencer::type_id::create("rsqr", this);
          wdrv = axi_wdriver::type_id::create("wdrv", this);
          rdrv = axi_rdriver::type_id::create("rdrv", this);
          vseqr = axi_virtual_sequencer::type_id::create("vseqr",this);
        end
        mon = axi_monitor::type_id::create("mon", this);
        ap = new("ap", this);
        cov  = axi_coverage::type_id::create("coverage", this);
      
    endfunction

      function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
          wdrv.seq_item_port.connect(wsqr.seq_item_export);
          rdrv.seq_item_port.connect(rsqr.seq_item_export);
          vseqr.write_sequencer = wsqr;
          vseqr.read_sequencer = rsqr;
   
        end
        
         mon.ap.connect(ap);
         mon.ap.connect(cov.analysis_export);

      
    endfunction
  
endclass

