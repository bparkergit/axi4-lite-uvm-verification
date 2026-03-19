class axi_write_sequence extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(axi_write_sequence)
  
        
  axi_seq_item item;    
  bit [31:0] addr, data;
  
    function new(string name = "axi_base_sequence");
        super.new(name);
    endfunction
  
    task body();
    
      // WRITE
      begin   
      		item = axi_seq_item::type_id::create("item");
            start_item(item);
            assert(item.randomize() with {
                is_write == 1;
            }) else `uvm_error("RAND_FAIL", "Write randomization failed")

                
              `uvm_info("SEQ", $sformatf("WRITE: addr=0x%08h wdata=0x%08h wstrb=0x%h",item.s_axi_awaddr, item.s_axi_wdata, item.s_axi_wstrb), UVM_LOW)

            
            addr = item.s_axi_awaddr;
        	data = item.s_axi_wdata;
        
            finish_item(item);
        
      end

      
      
    endtask
endclass
