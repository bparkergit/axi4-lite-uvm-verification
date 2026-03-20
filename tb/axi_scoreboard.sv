`uvm_analysis_imp_decl(_w)
`uvm_analysis_imp_decl(_aw)

class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)

    // Analysis port from monitor
    uvm_analysis_imp #(axi_seq_item, axi_scoreboard) imp;
  uvm_analysis_imp_w #(axi_seq_item, axi_scoreboard) imp_w;
  uvm_analysis_imp_aw #(axi_seq_item, axi_scoreboard) imp_aw;
  
    virtual axi_if vif;

	// buffer txn as they arrive
    axi_seq_item aw_q[$];
    axi_seq_item w_q[$];
    axi_seq_item r_q[$];
    axi_seq_item ar_q[$];
  
    // Memory model: address → expected 32-bit data
    bit [31:0] model_mem[bit [31:0]];


    // Local variables for write()
    bit [31:0] addr;
    bit [31:0] current;
    bit [3:0] wstrb;
    bit [31:0] masked_data;
    int        byte_idx;

    // Local variables for read comparison
    bit [31:0] data;
    bit [31:0] expected;

    function new(string name = "axi_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      imp = new("imp", this);      
      imp_w = new("imp_w", this);
      imp_aw = new("imp_aw", this);

      if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
          `uvm_fatal("NO_VIF", "Virtual interface not set in scoreboard")
    endfunction

    // ───────────────────────────────────────────────
    // Main write function - called for every transaction
    // ───────────────────────────────────────────────    
          
         
        
  virtual function void write_w(axi_seq_item txn);
      `uvm_info("DBG", $sformatf("pushing Wstrb on q=%0b", txn.s_axi_wstrb), UVM_MEDIUM)
                
                  w_q.push_back(txn);
 	  			  try_match();
  endfunction
          
          
  virtual function void write_aw(axi_seq_item txn);
                  aw_q.push_back(txn);
 	  			  try_match();
  endfunction
          
  
    function try_match();
      `uvm_info("DBG", $sformatf("AW_Q=%0d W_Q=%0d", aw_q.size(), w_q.size()), UVM_MEDIUM)
      
        if (aw_q.size() > 0 && w_q.size() > 0) begin
          axi_seq_item aw = aw_q.pop_front();
          axi_seq_item w  = w_q.pop_front();

          
          addr = aw.s_axi_awaddr;  // word-aligned


          current = model_mem.exists(addr) ? model_mem[addr] : 0;
          masked_data = current;

          for (byte_idx = 0; byte_idx < 4; byte_idx++) begin
            if (w.s_axi_wstrb[byte_idx]) begin
                  masked_data[byte_idx*8 +: 8] = w.s_axi_wdata[byte_idx*8 +: 8];
            end
          end

        
          model_mem[addr] = masked_data;

          `uvm_info("SCB_WR", $sformatf("Write addr 0x%08h: masked data=0x%08h (wstrb=0x%h)", 
                                          addr, masked_data, w.s_axi_wstrb), UVM_LOW)
        end
      
    endfunction
  
  
    virtual function void write(axi_seq_item txn);

        // Handle reads
      if (txn.s_axi_arvalid && txn.s_axi_arready)begin 
            ar_q.push_back(txn);
       
      end
      

        

      if(txn.s_axi_rvalid && txn.s_axi_rready) begin
        
        if(ar_q.size() == 0 || r_q.size() == 0)
                r_q.push_back(txn);   
              else begin
            	addr = ar_q.pop_front().s_axi_araddr ;
                data = r_q.pop_front().s_axi_wdata;
                
            expected = model_mem.exists(addr) ? model_mem[addr] : 0;

            `uvm_info("SCB_RD", $sformatf("Read addr 0x%08h: got=0x%08h  exp=0x%08h", 
                                           addr, data, expected), UVM_LOW)

            // Check for X/Z
            if ($isunknown(txn.s_axi_rdata)) begin
                    `uvm_error("X_DETECTED", $sformatf("Read data X/Z at 0x%08h: %0h", addr, txn.s_axi_rdata))
                    return;   
            end

            // Compare
            if (txn.s_axi_rdata !== expected) begin
                `uvm_error("DATA_MISMATCH", 
                           $sformatf("Addr 0x%08h: exp 0x%08h  got 0x%08h", 
                                     addr, expected, txn.s_axi_rdata))
            
             end else
              `uvm_info("MATCH", $sformatf("Addr 0x%08h: 0x%08h OK", addr, txn.s_axi_rdata), UVM_LOW)
              
              end
        end
    endfunction

    // Reset handling
    virtual task run_phase(uvm_phase phase);
        forever begin
          @(negedge vif.aresetn) begin
            model_mem.delete();

          `uvm_info("SCB_RST", "Scoreboard model cleared on reset", UVM_LOW)
          end
        end
    endtask

endclass