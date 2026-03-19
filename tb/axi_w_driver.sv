class axi_w_driver extends uvm_driver #(axi_seq_item);
  `uvm_component_utils(axi_w_driver)
  
  virtual axi_if.DRIVER vif;
  
  function new(string name = "axi_w_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // get the vif from config_db
      
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual axi_if.DRIVER)::get(this, "", "vif", vif))
            `uvm_fatal("DRV_NOVIF", "Driver virtual interface not set")
  endfunction
          
      
       
task run_phase(uvm_phase phase);    
    axi_seq_item item; 
		vif.cb_drv.s_axi_wvalid  <= 0;
    
        forever begin
          seq_item_port.get_next_item(item);
        
          if(item.is_write)
              drive_w_channel(item);
          
            seq_item_port.item_done();
        end
endtask
        
        
 task drive_w_channel(axi_seq_item item);


        // Data channel
   repeat(item.w_delay) @(vif.cb_drv);
          
        vif.cb_drv.s_axi_wdata  <= item.s_axi_wdata;
        vif.cb_drv.s_axi_wstrb  <= item.s_axi_wstrb;

        // Write data valid wait for ready
        vif.cb_drv.s_axi_wvalid <= 1;

        wait(vif.cb_drv.s_axi_wready);
        @(vif.cb_drv);
        vif.cb_drv.s_axi_wvalid <= 0;



endtask
             
        
endclass

  
