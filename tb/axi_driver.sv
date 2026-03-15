class axi_driver extends uvm_driver #(axi_seq_item);
  `uvm_component_utils(axi_driver)
  
  virtual axi_if.DRIVER vif;
  
  function new(string name = "axi_driver", uvm_component parent = null);
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
        vif.cb_drv.s_axi_awvalid <= 0;
		vif.cb_drv.s_axi_wvalid  <= 0;
		vif.cb_drv.s_axi_arvalid <= 0;
		vif.cb_drv.s_axi_bready  <= 0;
		vif.cb_drv.s_axi_rready  <= 0;
        
        
        forever begin
          seq_item_port.get_next_item(item);
          
          if(item.s_axi_wvalid)
              drive_write(item);
          else if(item.s_axi_arvalid)
              drive_read(item);
         
          
            seq_item_port.item_done();
        end
    endtask
        
    task drive_write(axi_seq_item item);

      fork
        
        begin
        // Address channel
        vif.cb_drv.s_axi_awaddr  <= item.s_axi_awaddr;

        // Write address valid wait for ready
        vif.cb_drv.s_axi_awvalid <= 1;

        wait(vif.cb_drv.s_axi_awready);
        @(posedge vif.cb_drv);
        vif.cb_drv.s_axi_awvalid <= 0;

        end
        
        begin
        // Data channel
        vif.cb_drv.s_axi_wdata  <= item.s_axi_wdata;
        vif.cb_drv.s_axi_wstrb  <= item.s_axi_wstrb;

        // Write data valid wait for ready
        vif.cb_drv.s_axi_wvalid <= 1;

        wait(vif.cb_drv.s_axi_wready);
        @(posedge vif.cb_drv);
        vif.cb_drv.s_axi_wvalid <= 0;
        end

      join
      
    // Write response channel wait for valid
    vif.cb_drv.s_axi_bready <= 1;

    wait(vif.cb_drv.s_axi_bvalid);
    @(posedge vif.cb_drv);
    vif.cb_drv.s_axi_bready <= 0;

  	endtask
        
        
    task drive_read(axi_seq_item item); 
      
      vif.cb_drv.s_axi_araddr <= item.s_axi_araddr;
      vif.cb_drv.s_axi_arprot   <= item.s_axi_arprot;
     
      
      // Adress wait for ready then valid goes low
      vif.cb_drv.s_axi_arvalid   <= 1;
      
      wait(vif.cb_drv.s_axi_arready);
      @(posedge vif.cb_drv);
      vif.cb_drv.s_axi_arvalid <= 0;
      
      // Data ready wait for valid then ready goes low
      vif.cb_drv.s_axi_rready <= 1;
      
      wait(vif.cb_drv.s_axi_rvalid);
      @(vif.cb_drv);
      vif.cb_drv.s_axi_rready <= 0;
      
    endtask
        
        
endclass

  
