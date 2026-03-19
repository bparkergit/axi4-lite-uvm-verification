class axi_read_sequence extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(axi_read_sequence)
  
       
  axi_seq_item item;   
  bit [31:0] addr,data;
  
    function new(string name = "axi_base_sequence");
        super.new(name);
    endfunction
  
    task body();

        
      // READ
      begin 
            item = axi_seq_item::type_id::create("item");
        
            start_item(item);
        
            assert(item.randomize() with {
                is_write == 0;
                s_axi_araddr == addr;
            }) else `uvm_error("RAND_FAIL", "Read randomization failed")

              `uvm_info("SEQ", $sformatf("READ:  addr=0x%08h", item.s_axi_araddr), UVM_LOW)

              addr = item.s_axi_araddr;       
              data = item.s_axi_rdata;
            finish_item(item);
        

       end
      
      
      
    endtask
endclass
