class axi_coverage extends uvm_subscriber #(axi_seq_item) ;
  
  `uvm_component_utils(axi_coverage)
     
  typedef enum {AW_FIRST, W_FIRST, SAME} order_e;
  

  bit [31:0] addr;
  bit [1:0]  resp;
  bit [3:0]  wstrb;
  bit	w_seen, aw_seen, is_write;
  
  time w_time, aw_time;
  int aw_w_order;
  
  
  covergroup cg_transaction;

  
    cp_wstrb : coverpoint wstrb {
      bins all_combinations[] = {[0:15]};
    }
    
    cp_is_write : coverpoint is_write {
      bins read  = {0};
      bins write = {1};
  	}
    
    cp_addr : coverpoint addr {
      bins reg0 = {0};
      bins reg1 = {4};
      bins reg2 = {8};
      bins reg3 = {12};
    }
    

    cp_resp : coverpoint resp {
      bins OKAY   = {2'b00};
      bins SLVERR = {2'b10};
    }
    
    
    cp_aw_w_order : coverpoint aw_w_order {
      bins aw_first = {AW_FIRST};
      bins w_first  = {W_FIRST};
      bins same     = {SAME};
    }
      
      
      // Cover the cases where AW happens before W and W happens before AW need to use $realtime
      
  
      cross cp_is_write, cp_addr;
    
      cross cp_aw_w_order, cp_is_write{
            ignore_bins invalid_aw =
        binsof(cp_is_write) intersect {0} && binsof(cp_aw_w_order) intersect {AW_FIRST};
        	ignore_bins invalid_w =
        binsof(cp_is_write) intersect {0} && binsof(cp_aw_w_order) intersect {W_FIRST};
      }
      
    endgroup
  
       
  function new(string name="axi_coverage", uvm_component parent);
          super.new(name, parent);
          cg_transaction = new();
          cg_transaction.set_inst_name("cg_transaction");  // helps reporting
    endfunction
  
  
    // This is called automatically via analysis_export
    virtual function void write(axi_seq_item t);
      `uvm_info("COV_SAMPLE", $sformatf("Sampling txn: s_axi_wvalid=%0b s_axi_arready=%0b",t.s_axi_wvalid, t.s_axi_arready), UVM_MEDIUM)
      

      	is_write = t.is_write;
      
      if(is_write) begin
        
        if (t.w_seen) begin  
          w_seen = t.w_seen;
          w_time = $time;
        end

        if(t.aw_seen) begin
          aw_seen = t.aw_seen;
          aw_time = $time;
        end
            
        addr = t.s_axi_awaddr;     
        wstrb = t.s_axi_wstrb;

   
        if(w_seen && aw_seen) begin
          if (aw_time < w_time)
            aw_w_order = AW_FIRST;
          else if (w_time < aw_time)
            aw_w_order = W_FIRST;
          else
            aw_w_order = SAME;
        end
        
      end
      else
          addr = t.s_axi_araddr;
      
      
        resp     = t.s_axi_bresp;
      
        cg_transaction.sample();

  endfunction
  
  
  
endclass
