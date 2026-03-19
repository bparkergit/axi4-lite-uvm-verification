class axi_w_sequence extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(axi_w_sequence)
  
        
  axi_seq_item item;    
  bit [31:0] data;
  bit [3:0] wstrb;
  
  function new(string name = "axi_w_sequence");
        super.new(name);
    endfunction
  
    task body();
    
      // WRITE
      begin   
      		item = axi_seq_item::type_id::create("item");
            start_item(item);
            assert(item.randomize() with {
              is_write == 1;
              s_axi_wstrb == wstrb;
              s_axi_wdata == data;
            }) else `uvm_error("RAND_FAIL", "Write randomization failed")

                
              `uvm_info("SEQ", $sformatf("WRITE W: wdata=0x%08h wstrb=0x%h",item.s_axi_wdata, item.s_axi_wstrb), UVM_LOW)
      		
            
        finish_item(item);
        
      end

      
      
    endtask
endclass