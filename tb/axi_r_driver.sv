class axi_r_driver extends uvm_driver #(axi_seq_item);
  `uvm_component_utils(axi_r_driver)
  
  virtual axi_if.DRIVER vif;
  
  function new(string name = "axi_r_driver", uvm_component parent = null);     
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
		    vif.cb_drv.s_axi_arvalid <= 0;
        
        forever begin
          seq_item_port.get_next_item(item);
        
          fork begin
            drive_ar_channel(item);
            drive_r_channel(item);
          end
          join
              
          seq_item_port.item_done();

        end
  endtask
        

        
  task drive_r_channel(axi_seq_item item); 
      
  repeat(item.r_delay) @(vif.cb_drv); // random delayed start
  

      // Adress wait for ready then valid goes low
      vif.cb_drv.s_axi_rready   <= 1;
      
    wait(vif.cb_drv.s_axi_rvalid);
      @(vif.cb_drv);
      vif.cb_drv.s_axi_rready <= 0;
     
      
  endtask
    
     task drive_ar_channel(axi_seq_item item);


        // Data channel
   repeat(item.ar_delay) @(vif.cb_drv);
          
        vif.cb_drv.s_axi_araddr  <= item.s_axi_araddr;

        // Read address valid wait for ready
        vif.cb_drv.s_axi_arvalid <= 1;

        wait(vif.cb_drv.s_axi_arready);
        @(vif.cb_drv);
        vif.cb_drv.s_axi_arvalid <= 0;



endtask
    
        
        
endclass

  
