class axi_seq_item extends uvm_sequence_item;
  
  // Use the **param** version of the macro
  `uvm_object_param_utils(axi_seq_item)
  
    // Write Address Channel
    rand  bit [32-1:0]    s_axi_awaddr;
    rand  bit [2:0]               s_axi_awprot;
    rand  bit                     s_axi_awvalid;
    bit                    		  s_axi_awready;
	
    // Write Data Channel
    rand  bit [32-1:0]    s_axi_wdata;
    rand  bit [32/8-1:0]  s_axi_wstrb;
    rand  bit                     s_axi_wvalid;
    bit                      	  s_axi_wready;

    // Write Response Channel
    bit  [1:0]             		  s_axi_bresp;
    bit                		      s_axi_bvalid;
    rand  bit          		      s_axi_bready;

    // Read Address Channel
    rand  bit [32-1:0]    s_axi_araddr;
    rand  bit [2:0]               s_axi_arprot;
    rand  bit                     s_axi_arvalid;
    bit                  		  s_axi_arready;

    // Read Data Channel
    bit  [32-1:0]   	  s_axi_rdata;
    bit  [1:0]     				  s_axi_rresp;
    bit					  		  s_axi_rvalid;
    rand  bit                	  s_axi_rready;
  
  
  	rand int aw_delay;
  	rand int w_delay;
  	rand int r_delay;
    rand int bready_delay;
  
  	rand	bit	is_write;
    rand int aw_w_order;
  
    constraint delay_dist {
      aw_delay dist {0 := 1, [1:5] := 9};
      w_delay  dist {0 := 1, [1:5] := 9};
      r_delay  dist {0 := 5, [1:5] := 5};
      bready_delay dist {0 := 5, [1:5] := 5};
    }
  
    constraint aw_cons {
      s_axi_awaddr inside {0, 4, 8, 12};
    }
    
    constraint ar_cons {
      s_axi_araddr inside {0, 4, 8, 12};
    }
	

  
    function new(string name = "axi_seq_item");
        super.new(name);
    endfunction
  
endclass
