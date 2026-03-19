class wr_rd_vseq extends uvm_sequence;
  `uvm_object_utils(wr_rd_vseq)

  `uvm_declare_p_sequencer(axi_virtual_sequencer)
  
  axi_read_sequence rd_seq;
  axi_write_sequence wr_seq;
   
  bit [31:0] addr, wdata;
  
    
  function new(string name = "wr_rd_vseq");   
    super.new(name);  
  endfunction
  
  
  task body();    
    
    repeat(30) begin
    // ---------------- WRITE ----------------
    wr_seq = axi_write_sequence::type_id::create("wr_seq");

    wr_seq.start(p_sequencer.write_sequencer); 


    addr  = wr_seq.addr;
    wdata = wr_seq.data;

    // ---------------- READ ----------------
    rd_seq = axi_read_sequence::type_id::create("rd_seq");

    rd_seq.addr = addr;

    rd_seq.start(p_sequencer.read_sequencer); 
    

    end
    
  endtask
endclass
