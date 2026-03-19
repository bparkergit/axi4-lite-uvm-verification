class axi_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(axi_virtual_sequencer)

  axi_sequencer read_sequencer;
  axi_sequencer write_sequencer;

  function new(string name = "axi_virtual_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
endclass
