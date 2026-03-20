class axi_base_test extends uvm_test;
  `uvm_component_utils(axi_base_test)
  
	axi_env env;
    wr_rd_vseq vseq;
  
    
  function new(string name = "axi_base_test", uvm_component parent);     
    super.new(name,parent);      
  endfunction
      
  
  function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = axi_env::type_id::create("env", this);
    
  endfunction
    
      
  task run_phase(uvm_phase phase);

        phase.raise_objection(this);

    `uvm_info(get_type_name(), "Starting write then read sequence", UVM_LOW)

          vseq = wr_rd_vseq::type_id::create("vseq");
          vseq.start(env.vseqr);
          

        #1000ns;   // give time to observe behavior

        phase.drop_objection(this);
  
  endtask
    
endclass