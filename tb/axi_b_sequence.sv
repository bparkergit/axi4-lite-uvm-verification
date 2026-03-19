class axi_b_sequence extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(axi_b_sequence)
  
        
  axi_seq_item item;    

  
  function new(string name = "axi_b_sequence");
        super.new(name);
    endfunction
  
    task body();
    
      // WRITE
      begin   
      		
        item = axi_seq_item::type_id::create("item"); 
        start_item(item);       
        assert(item.randomize());
                       
        `uvm_info("SEQ", $sformatf("WRITE B: wdata=0x%08h wstrb=0x%h",item.s_axi_wdata, item.s_axi_wstrb), UVM_LOW)
     
        finish_item(item);
        
      end

      
      
    endtask
endclass