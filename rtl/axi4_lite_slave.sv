module axi4_lite_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  logic aclk,
    input  logic aresetn,

    // Write Address Channel
    input  logic [ADDR_WIDTH-1:0] s_axi_awaddr,
    input  logic [2:0]            s_axi_awprot,
    input  logic                  s_axi_awvalid,
    output logic                  s_axi_awready,

    // Write Data Channel
    input  logic [DATA_WIDTH-1:0] s_axi_wdata,
    input  logic [DATA_WIDTH/8-1:0] s_axi_wstrb,
    input  logic                  s_axi_wvalid,
    output logic                  s_axi_wready,

    // Write Response Channel
    output logic [1:0]            s_axi_bresp,
    output logic                  s_axi_bvalid,
    input  logic                  s_axi_bready,

    // Read Address Channel
    input  logic [ADDR_WIDTH-1:0] s_axi_araddr,
    input  logic [2:0]            s_axi_arprot,
    input  logic                  s_axi_arvalid,
    output logic                  s_axi_arready,

    // Read Data Channel
    output logic [DATA_WIDTH-1:0] s_axi_rdata,
    output logic [1:0]            s_axi_rresp,
    output logic                  s_axi_rvalid,
    input  logic                  s_axi_rready
);

////////////////////////////////////////////////////////////
// Register file
////////////////////////////////////////////////////////////
logic [DATA_WIDTH-1:0] regfile [0:3];

////////////////////////////////////////////////////////////
// Internal registers
////////////////////////////////////////////////////////////
logic [ADDR_WIDTH-1:0] awaddr_reg;
logic [DATA_WIDTH-1:0] wdata_reg;
logic [DATA_WIDTH/8-1:0] wstrb_reg;

logic aw_valid;
logic w_valid;

logic [ADDR_WIDTH-1:0] araddr_reg;
logic ar_valid;

////////////////////////////////////////////////////////////
// WRITE ADDRESS CHANNEL
////////////////////////////////////////////////////////////
always_ff @(posedge aclk) begin
    if (!aresetn) begin
        s_axi_awready <= 1'b1;
        aw_valid      <= 1'b0;
    end else begin

        if (s_axi_awvalid && s_axi_awready) begin
            awaddr_reg <= s_axi_awaddr;
            aw_valid   <= 1'b1;
        end

        // Ready again after transaction completes
        if (s_axi_bvalid && s_axi_bready) begin
            aw_valid <= 1'b0;
        end

        s_axi_awready <= !aw_valid;

    end
end

////////////////////////////////////////////////////////////
// WRITE DATA CHANNEL
////////////////////////////////////////////////////////////
always_ff @(posedge aclk) begin
    if (!aresetn) begin
        s_axi_wready <= 1'b1;
        w_valid      <= 1'b0;
    end else begin

        if (s_axi_wvalid && s_axi_wready) begin
            wdata_reg <= s_axi_wdata;
            wstrb_reg <= s_axi_wstrb;  // ✅ LATCH STRB HERE
            w_valid   <= 1'b1;
        end

        if (s_axi_bvalid && s_axi_bready) begin
            w_valid <= 1'b0;
        end

        s_axi_wready <= !w_valid;

    end
end

////////////////////////////////////////////////////////////
// WRITE EXECUTION + RESPONSE
////////////////////////////////////////////////////////////
always_ff @(posedge aclk) begin
    if (!aresetn) begin
        s_axi_bvalid <= 1'b0;
        s_axi_bresp  <= 2'b00;
    end else begin

        // Perform write when both channels are valid
        if (aw_valid && w_valid && !s_axi_bvalid) begin

            for (int i = 0; i < DATA_WIDTH/8; i++) begin
                if (wstrb_reg[i]) begin
                    regfile[awaddr_reg[3:2]][8*i +: 8] <= wdata_reg[8*i +: 8];
                end
            end

            s_axi_bvalid <= 1'b1;
            s_axi_bresp  <= 2'b00; // OKAY

        end

        if (s_axi_bvalid && s_axi_bready) begin
            s_axi_bvalid <= 1'b0;
        end

    end
end

////////////////////////////////////////////////////////////
// READ ADDRESS CHANNEL
////////////////////////////////////////////////////////////
always_ff @(posedge aclk) begin
    if (!aresetn) begin
        s_axi_arready <= 1'b1;
        ar_valid      <= 1'b0;
    end else begin

        if (s_axi_arvalid && s_axi_arready) begin
            araddr_reg <= s_axi_araddr;
            ar_valid   <= 1'b1;
        end

        if (s_axi_rvalid && s_axi_rready) begin
            ar_valid <= 1'b0;
        end

        s_axi_arready <= !ar_valid;

    end
end

////////////////////////////////////////////////////////////
// READ DATA CHANNEL
////////////////////////////////////////////////////////////
always_ff @(posedge aclk) begin
    if (!aresetn) begin
        s_axi_rvalid <= 1'b0;
        s_axi_rresp  <= 2'b00;
        s_axi_rdata  <= '0;
    end else begin

        if (ar_valid && !s_axi_rvalid) begin
            s_axi_rdata  <= regfile[araddr_reg[3:2]];
            s_axi_rvalid <= 1'b1;
            s_axi_rresp  <= 2'b00;
        end

        if (s_axi_rvalid && s_axi_rready) begin
            s_axi_rvalid <= 1'b0;
        end

    end
end

endmodule