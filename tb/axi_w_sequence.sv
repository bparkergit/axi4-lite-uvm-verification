class axi_w_sequence extends uvm_sequence #(axi_seq_item);
  `uvm_object_utils(axi_w_sequence)
  
        
  axi_seq_item item;    
  bit [31:0] data;
  bit [31:0] addr;
  bit [3:0] wstrb;
  
  function new(string name = "axi_w_sequence");
        super.new(name);
    endfunction
  
    task body();
    
    axi_seq_item aw_item, w_item, b_item;

    // Drive AW
    aw_item = axi_seq_item::type_id::create("aw_item");
    aw_item.s_axi_awaddr = addr;

    start_item(aw_item);
    finish_item(aw_item);

    // Drive W
    w_item = axi_seq_item::type_id::create("w_item");
    w_item.s_axi_wdata = data;
    w_item.s_axi_wstrb = wstrb;

    start_item(w_item);
    finish_item(w_item);

    // Wait for B
    b_item = axi_seq_item::type_id::create("b_item");

    start_item(b_item);
    finish_item(b_item);
      
      
    endtask
endclass