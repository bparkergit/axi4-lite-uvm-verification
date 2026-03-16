class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)

    // Analysis port from monitor
    uvm_analysis_imp #(axi_seq_item, axi_scoreboard) imp;

    virtual axi_if vif;

    // Memory model: address → expected 32-bit data
    bit [31:0] model_mem[bit [31:0]];

    // Debug counters
    int write_count;
    int read_count;

    // Local variables for write()
    bit [31:0] addr;
    bit [31:0] current;
    bit [31:0] masked_data;
    int        byte_idx;

    // Local variables for read comparison
    bit [31:0] expected;

    function new(string name = "axi_scoreboard", uvm_component parent);
        super.new(name, parent);
        write_count = 0;
        read_count  = 0;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        imp = new("imp", this);

        if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Virtual interface not set in scoreboard")
    endfunction

    // ───────────────────────────────────────────────
    // Main write function - called for every transaction
    // ───────────────────────────────────────────────
    virtual function void write(axi_seq_item txn);

        // Handle writes
      if (txn.s_axi_wvalid && txn.s_axi_wready) begin
            addr = txn.s_axi_awaddr & ~32'h3;  // word-aligned

            current = model_mem.exists(addr) ? model_mem[addr] : 0;
            masked_data = current;

            for (byte_idx = 0; byte_idx < 4; byte_idx++) begin
                if (txn.s_axi_wstrb[byte_idx]) begin
                    masked_data[byte_idx*8 +: 8] = txn.s_axi_wdata[byte_idx*8 +: 8];
                end
            end

            model_mem[addr] = masked_data;

            write_count++;
            `uvm_info("SCB_WR", $sformatf("Write addr 0x%08h: data=0x%08h (wstrb=0x%h)", 
                                          addr, masked_data, txn.s_axi_wstrb), UVM_LOW)
        end

        // Handle reads
        if (txn.s_axi_rvalid && txn.s_axi_rready) begin
            addr = txn.s_axi_araddr & ~32'h3;

            expected = model_mem.exists(addr) ? model_mem[addr] : 0;

            read_count++;
            `uvm_info("SCB_RD", $sformatf("Read addr 0x%08h: got=0x%08h  exp=0x%08h", 
                                          addr, txn.s_axi_rdata, expected), UVM_LOW)

            // Check for X/Z
            if ($isunknown(txn.s_axi_rdata)) begin
                `uvm_error("X_DETECTED", $sformatf("Read data X/Z at 0x%08h: %0h", addr, txn.s_axi_rdata))
                return;
            end

            // Compare
            if (txn.s_axi_rdata !== expected) begin
                `uvm_error("DATA_MISMATCH", 
                           $sformatf("Addr 0x%08h: exp 0x%08h  got 0x%08h", 
                                     addr, expected, txn.s_axi_rdata))
            end else begin
              `uvm_info("MATCH", $sformatf("Addr 0x%08h: 0x%08h OK", addr, txn.s_axi_rdata), UVM_LOW)
            end
        end
    endfunction

    // Reset handling
    virtual task run_phase(uvm_phase phase);
        forever begin
            @(negedge vif.aresetn);
            model_mem.delete();
            write_count = 0;
            read_count  = 0;
            `uvm_info("SCB_RST", "Scoreboard model cleared on reset", UVM_LOW)
        end
    endtask

endclass
