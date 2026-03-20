module axi4_lite_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic                      aclk,
    input  logic                      aresetn,

    // Write Address Channel
    input  logic [ADDR_WIDTH-1:0]     s_axi_awaddr,
    input  logic [2:0]                s_axi_awprot,
    input  logic                      s_axi_awvalid,
    output logic                      s_axi_awready,

    // Write Data Channel
    input  logic [DATA_WIDTH-1:0]     s_axi_wdata,
    input  logic [DATA_WIDTH/8-1:0]   s_axi_wstrb,
    input  logic                      s_axi_wvalid,
    output logic                      s_axi_wready,

    // Write Response Channel
    output logic [1:0]                s_axi_bresp,
    output logic                      s_axi_bvalid,
    input  logic                      s_axi_bready,

    // Read Address Channel
    input  logic [ADDR_WIDTH-1:0]     s_axi_araddr,
    input  logic [2:0]                s_axi_arprot,
    input  logic                      s_axi_arvalid,
    output logic                      s_axi_arready,

    // Read Data Channel
    output logic [DATA_WIDTH-1:0]     s_axi_rdata,
    output logic [1:0]                s_axi_rresp,
    output logic                      s_axi_rvalid,
    input  logic                      s_axi_rready
);

    // Register file
    logic [DATA_WIDTH-1:0] regfile [0:3];

    // Write address state
    logic                      awaddr_valid;
    logic [ADDR_WIDTH-1:0]     awaddr_latched;

    // Write data state
    logic                      wdata_valid;
    logic [DATA_WIDTH-1:0]     wdata_latched;
    logic [DATA_WIDTH/8-1:0]   wstrb_latched;

    // Read state
    logic                      araddr_valid;
    logic [ADDR_WIDTH-1:0]     araddr_latched;

    // Write Address Channel
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axi_awready   <= 1'b1;
            awaddr_valid    <= 1'b0;
            awaddr_latched  <= '0;
        end else begin
            if (s_axi_awvalid && s_axi_awready) begin
                awaddr_latched  <= s_axi_awaddr;
                awaddr_valid    <= 1'b1;
            end

            // Clear only after B handshake
            if (s_axi_bvalid && s_axi_bready) begin
                awaddr_valid    <= 1'b0;
            end

            s_axi_awready <= !awaddr_valid;
        end
    end

    // Write Data Channel
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axi_wready    <= 1'b1;
            wdata_valid     <= 1'b0;
            wdata_latched   <= '0;
            wstrb_latched   <= '0;
        end else begin
            if (s_axi_wvalid && s_axi_wready) begin
                wdata_latched   <= s_axi_wdata;
                wstrb_latched   <= s_axi_wstrb;
                wdata_valid     <= 1'b1;
            end

            // Clear only after B handshake
            if (s_axi_bvalid && s_axi_bready) begin
                wdata_valid     <= 1'b0;
            end

            s_axi_wready <= !wdata_valid;
        end
    end

    // Write Execution + Response
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axi_bvalid <= 1'b0;
            s_axi_bresp  <= 2'b00;

            for (int i = 0; i < 4; i++) regfile[i] <= '0;
        end else begin
            if (awaddr_valid && wdata_valid && !s_axi_bvalid) begin
                automatic logic [DATA_WIDTH-1:0] current = regfile[awaddr_latched[3:2]];

                for (int i = 0; i < DATA_WIDTH/8; i++) begin
                    if (wstrb_latched[i]) begin
                        current[8*i +: 8] = wdata_latched[8*i +: 8];
                    end
                end

                regfile[awaddr_latched[3:2]] <= current;

                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00;
            end

            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end
        end
    end

    // Read Address Channel
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axi_arready   <= 1'b1;
            araddr_valid    <= 1'b0;
            araddr_latched  <= '0;
        end else begin
            if (s_axi_arvalid && s_axi_arready) begin
                araddr_latched  <= s_axi_araddr;
                araddr_valid    <= 1'b1;
            end

            if (s_axi_rvalid && s_axi_rready) begin
                araddr_valid    <= 1'b0;
            end

            s_axi_arready <= !araddr_valid;
        end
    end

    // Read Data Channel
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axi_rvalid <= 1'b0;
            s_axi_rresp  <= 2'b00;
            s_axi_rdata  <= '0;
        end else begin
            if (araddr_valid && !s_axi_rvalid) begin
                s_axi_rdata  <= regfile[araddr_latched[3:2]];
                s_axi_rvalid <= 1'b1;
                s_axi_rresp  <= 2'b00;
            end

            if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

endmodule