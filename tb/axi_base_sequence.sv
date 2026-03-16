class axi_base_sequence extends uvm_sequence #(axi_seq_item);
    `uvm_object_utils(axi_base_sequence)
  
    function new(string name = "axi_base_sequence");
        super.new(name);
    endfunction
  
    task body();
        axi_seq_item item;
        bit [31:0] write_addr;

        repeat(30) begin   // 30 pairs → 60 txns
      
            // Step 1: WRITE
      		item = axi_seq_item::type_id::create("item");
            start_item(item);
            assert(item.randomize() with {
                s_axi_wvalid == 1;
                s_axi_arvalid == 0;
                s_axi_awaddr inside {0, 4, 8, 12};
                s_axi_awaddr[1:0] == 0;
                s_axi_wstrb dist {4'b1111 := 70, [1:14] := 30};  
                s_axi_rready == 1'b1;
            }) else `uvm_error("RAND_FAIL", "Write randomization failed")

            write_addr = item.s_axi_awaddr;

            `uvm_info("SEQ", $sformatf("WRITE: addr=0x%08h wdata=0x%08h wstrb=0x%h",
                                       item.s_axi_awaddr, item.s_axi_wdata, item.s_axi_wstrb), UVM_LOW)

            finish_item(item);

            // Step 2: READ same address
            item = axi_seq_item::type_id::create("item");
            start_item(item);
            assert(item.randomize() with {
                s_axi_wvalid == 0;
                s_axi_araddr == write_addr;  // force same as previous write
                s_axi_araddr[1:0] == 0;
                s_axi_rready == 1'b1;
            }) else `uvm_error("RAND_FAIL", "Read randomization failed")

              `uvm_info("SEQ", $sformatf("READ:  addr=0x%08h", item.s_axi_araddr), UVM_LOW)

            finish_item(item);
        end
      
      
      repeat(5) begin   // 5 random writes
      		item = axi_seq_item::type_id::create("item");
            start_item(item);
            assert(item.randomize() with {
                s_axi_wvalid == 1;
                s_axi_arvalid == 0;
                s_axi_awaddr inside {0, 4, 8, 12};
                s_axi_awaddr[1:0] == 0;
                s_axi_wstrb dist {4'b1111 := 70, [1:14] := 30};  
                s_axi_rready == 1'b1;
            }) else `uvm_error("RAND_FAIL", "Write randomization failed")

                
            `uvm_info("SEQ", $sformatf("WRITE: addr=0x%08h wdata=0x%08h wstrb=0x%h",
                                       item.s_axi_awaddr, item.s_axi_wdata, item.s_axi_wstrb), UVM_LOW)

            finish_item(item);
        
              end
            
      repeat(5) begin // 5 random reads
            item = axi_seq_item::type_id::create("item");
            start_item(item);
            assert(item.randomize() with {
                s_axi_wvalid == 0;
              	s_axi_araddr inside {0, 4, 8, 12};
                s_axi_rready == 1'b1;
            }) else `uvm_error("RAND_FAIL", "Read randomization failed")

              `uvm_info("SEQ", $sformatf("READ:  addr=0x%08h", item.s_axi_araddr), UVM_LOW)

            finish_item(item);
        end
      
      
      
    endtask
endclass
