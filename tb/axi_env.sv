// ───────────────────────────────────────────────
//   ENVIRONMENT
// ───────────────────────────────────────────────
class axi_env extends uvm_env;

  `uvm_component_utils(axi_env)

    axi_r_agent r_agent;
    axi_w_agent w_agent;
  
  	axi_scoreboard scoreboard;
  
    axi_virtual_sequencer vseqr;

  function new(string name = "axi_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        r_agent = axi_r_agent::type_id::create("r_agent", this);
        w_agent = axi_w_agent::type_id::create("w_agent", this);
      	scoreboard = axi_scoreboard::type_id::create("scoreboard", this);
        vseqr = axi_virtual_sequencer::type_id::create("vseqr",this);
    endfunction
  
  function void connect_phase(uvm_phase phase);
    r_agent.ap.connect(scoreboard.imp);
    w_agent.w_ap.connect(scoreboard.imp_w);
    w_agent.aw_ap.connect(scoreboard.imp_aw);
    
    vseqr.w_sqr  = w_agent.sqr;
    vseqr.r_sqr  = r_agent.sqr;


  endfunction
  

endclass