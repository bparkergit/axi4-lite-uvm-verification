class wr_rd_vseq extends uvm_sequence;
  `uvm_object_utils(wr_rd_vseq)

  `uvm_declare_p_sequencer(axi_virtual_sequencer)
  
  axi_r_sequence r_seq;
  axi_w_sequence w_seq;
  axi_aw_sequence aw_seq;
  axi_b_sequence b_seq;
   
  bit [31:0] addr, wdata;
  
    
  function new(string name = "wr_rd_vseq");   
    super.new(name);  
  endfunction
  
  
  task body();    
    
    repeat(30) begin
    // ---------------- WRITE ----------------  
    aw_seq = axi_aw_sequence::type_id::create("aw_seq");
    w_seq = axi_w_sequence::type_id::create("w_seq");
    b_seq = axi_b_sequence::type_id::create("b_seq");
      

    aw_seq.addr = $urandom_range(0,255);
      w_seq.wstrb = $urandom_range(1,15);
    w_seq.data = $urandom_range(0,255);
      



      aw_seq.start(p_sequencer.aw_sqr);
      w_seq.start(p_sequencer.w_sqr);
      b_seq.start(p_sequencer.b_sqr); 

      
    addr  = aw_seq.addr;
    wdata = w_seq.data;

    // ---------------- READ ----------------
    r_seq = axi_r_sequence::type_id::create("r_seq");

    r_seq.addr = addr;

      r_seq.start(p_sequencer.r_sqr); 
    

    end
    
  endtask
endclass