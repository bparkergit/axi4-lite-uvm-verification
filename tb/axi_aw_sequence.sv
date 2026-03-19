class axi_aw_sequence extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(axi_aw_sequence)
  
        
  axi_seq_item item;    
  bit [31:0] addr;
  
  function new(string name = "axi_aw_sequence");
        super.new(name);
    endfunction
  
    task body();
    
      // WRITE
      begin   
      		item = axi_seq_item::type_id::create("item");
            start_item(item);
            assert(item.randomize() with {
                is_write == 1;
                s_axi_awaddr == addr;
            }) else `uvm_error("RAND_FAIL", "Write randomization failed")

                
              `uvm_info("SEQ", $sformatf("WRITE AW: addr=0x%08h",item.s_axi_awaddr), UVM_LOW)
      		
            
        	finish_item(item);
        
      end

      
      
    endtask
endclass