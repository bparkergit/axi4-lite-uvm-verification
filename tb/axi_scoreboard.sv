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
    bit [31:0] r_q[$];
    bit [31:0] ar_q[$];

    typedef struct {
        bit valid;
        bit [31:0] addr;
        bit [31:0] data;
        bit [3:0]  wstrb;

    } write_t;

	write_t write_buf[$];

  	axi_seq_item temp_item;
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
                  w_q.push_back(txn);
 	  			  try_match();
  endfunction
          
          
  virtual function void write_aw(axi_seq_item txn);
                  aw_q.push_back(txn);
 	  			  try_match();
  endfunction
          
  
    function try_match();
      
        if (aw_q.size() > 0 && w_q.size() > 0) begin
          axi_seq_item aw = aw_q.pop_front();
          axi_seq_item w  = w_q.pop_front();

          $display("DEBUG: aw_q.size=%0d w_q.size=%0d", aw_q.size(), w_q.size());
          $display("AW addr = %h", aw.s_axi_awaddr);
          $display("W data  = %h strb=%h", w.s_axi_wdata, w.s_axi_wstrb);
          
          
          addr = aw.s_axi_awaddr ;  // word-aligned


          current = model_mem.exists(addr[3:2]) ? model_mem[addr[3:2]] : 0;
          masked_data = current;

          for (byte_idx = 0; byte_idx < 4; byte_idx++) begin
            if (w.s_axi_wstrb[byte_idx]) begin
                  masked_data[byte_idx*8 +: 8] = w.s_axi_wdata[byte_idx*8 +: 8];
            end
          end

        
          model_mem[addr[3:2]] = masked_data;

          `uvm_info("SCB_WR", $sformatf("Write addr 0x%08h: masked data=0x%08h (wstrb=%b)", 
                                          addr, masked_data, w.s_axi_wstrb), UVM_LOW)
        end
      
    endfunction
  
  
    virtual function void write(axi_seq_item txn);

        // Handle reads
         
      if (txn.s_axi_arvalid && txn.s_axi_arready) begin  
        ar_q.push_back(txn.s_axi_araddr);
      end
       
      if (txn.s_axi_rvalid && txn.s_axi_rready) begin
        r_q.push_back(txn.s_axi_rdata);
      end
      
      if (ar_q.size() > 0 && r_q.size() > 0) begin
  		addr = ar_q.pop_front();
  		data = r_q.pop_front();

        expected = model_mem.exists(addr[3:2]) ? model_mem[addr[3:2]] : 0;
        
  	
        if (data !== expected)       
          `uvm_error("DATA_MISMATCH", $sformatf("Addr 0x%08h: exp 0x%08h  got 0x%08h", addr, expected, data))              
          else
            `uvm_info("MATCH", $sformatf("Addr 0x%08h: 0x%08h OK", addr, data), UVM_LOW)
            
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