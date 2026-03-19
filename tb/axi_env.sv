// ───────────────────────────────────────────────
//   ENVIRONMENT
// ───────────────────────────────────────────────
class axi_env extends uvm_env;

  `uvm_component_utils(axi_env)

    axi_r_agent r_agent;
    axi_ar_agent ar_agent;
    axi_w_agent w_agent;
    axi_aw_agent aw_agent;
  	axi_b_agent b_agent;
  	axi_scoreboard scoreboard;
  
    axi_virtual_sequencer vseqr;

  function new(string name = "axi_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        r_agent = axi_r_agent::type_id::create("r_agent", this);
        ar_agent = axi_ar_agent::type_id::create("ar_agent", this);
        w_agent = axi_w_agent::type_id::create("w_agent", this);
        aw_agent = axi_aw_agent::type_id::create("aw_agent", this);
        b_agent = axi_b_agent::type_id::create("b_agent", this);
      	scoreboard = axi_scoreboard::type_id::create("scoreboard", this);
        vseqr = axi_virtual_sequencer::type_id::create("vseqr",this);
    endfunction
  
  function void connect_phase(uvm_phase phase);
    r_agent.mon.ap.connect(scoreboard.imp);
    ar_agent.mon.ap.connect(scoreboard.imp);
    w_agent.mon.ap.connect(scoreboard.imp);
    aw_agent.mon.ap.connect(scoreboard.imp);
    b_agent.mon.ap.connect(scoreboard.imp);
    
    vseqr.w_sqr  = w_agent.sqr;
    vseqr.r_sqr  = r_agent.sqr;
    vseqr.aw_sqr = aw_agent.sqr;
    vseqr.ar_sqr = ar_agent.sqr;
    vseqr.b_sqr  = b_agent.sqr;

  endfunction
  

endclass