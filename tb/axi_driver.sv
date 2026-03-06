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
        forever begin
          seq_item_port.get_next_item(item);

          
            @(vif.cb_drv);
            vif.cb_drv.s_axi_awaddr   <= item.s_axi_awaddr;
            vif.cb_drv.s_axi_awprot <= item.s_axi_awprot;
            vif.cb_drv.s_axi_awvalid   <= item.s_axi_awvalid;

            vif.cb_drv.s_axi_wdata   <= item.s_axi_wdata;
            vif.cb_drv.s_axi_wstrb <= item.s_axi_wstrb;
            vif.cb_drv.s_axi_wvalid   <= item.s_axi_wvalid;
          
            vif.cb_drv.s_axi_bready   <= item.s_axi_bready;
          
            vif.cb_drv.s_axi_araddr <= item.s_axi_araddr;
            vif.cb_drv.s_axi_arprot   <= item.s_axi_arprot;
            vif.cb_drv.s_axi_arprot   <= item.s_axi_arprot;
            vif.cb_drv.s_axi_arvalid   <= item.s_axi_arvalid;

			vif.cb_drv.s_axi_rready   <= item.s_axi_rready;
          
            seq_item_port.item_done();
        end
    endtask
        
endclass

  