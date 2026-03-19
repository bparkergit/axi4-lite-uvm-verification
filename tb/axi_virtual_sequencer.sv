class axi_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(axi_virtual_sequencer)

  axi_sequencer ar_sqr;
  axi_sequencer aw_sqr;
  axi_sequencer r_sqr;
  axi_sequencer w_sqr;
  axi_sequencer b_sqr;
  
  
  function new(string name = "axi_virtual_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
endclass