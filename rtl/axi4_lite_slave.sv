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
// Simple Register File
////////////////////////////////////////////////////////////

logic [DATA_WIDTH-1:0] regfile [0:3];

////////////////////////////////////////////////////////////
// Write Channel Storage
////////////////////////////////////////////////////////////

logic [ADDR_WIDTH-1:0] awaddr_reg;
logic [DATA_WIDTH-1:0] wdata_reg;

logic aw_valid;
logic w_valid;

////////////////////////////////////////////////////////////
// Read Channel Storage
////////////////////////////////////////////////////////////

logic [ADDR_WIDTH-1:0] araddr_reg;
logic ar_valid;

////////////////////////////////////////////////////////////
// WRITE ADDRESS CHANNEL
////////////////////////////////////////////////////////////

always_ff @(posedge aclk) begin
    if(!aresetn) begin
        s_axi_awready <= 0;
        aw_valid      <= 0;
    end
    else begin

        s_axi_awready <= !aw_valid;

        if(s_axi_awvalid && s_axi_awready) begin
            awaddr_reg <= s_axi_awaddr;
            aw_valid   <= 1;
        end

        if(s_axi_bvalid && s_axi_bready)
            aw_valid <= 0;

    end
end

////////////////////////////////////////////////////////////
// WRITE DATA CHANNEL
////////////////////////////////////////////////////////////

always_ff @(posedge aclk) begin
    if(!aresetn) begin
        s_axi_wready <= 0;
        w_valid      <= 0;
    end
    else begin

        s_axi_wready <= !w_valid;

        if(s_axi_wvalid && s_axi_wready) begin
            wdata_reg <= s_axi_wdata;
            w_valid   <= 1;
        end

        if(s_axi_bvalid && s_axi_bready)
            w_valid <= 0;

    end
end

////////////////////////////////////////////////////////////
// WRITE EXECUTION + RESPONSE
////////////////////////////////////////////////////////////

always_ff @(posedge aclk) begin
    if(!aresetn) begin
        s_axi_bvalid <= 0;
        s_axi_bresp  <= 0;
    end
    else begin

        if(aw_valid && w_valid && !s_axi_bvalid) begin

            regfile[awaddr_reg[3:2]] <= wdata_reg;

            s_axi_bvalid <= 1;
            s_axi_bresp  <= 2'b00; // OKAY

        end

        if(s_axi_bvalid && s_axi_bready)
            s_axi_bvalid <= 0;

    end
end

////////////////////////////////////////////////////////////
// READ ADDRESS CHANNEL
////////////////////////////////////////////////////////////

always_ff @(posedge aclk) begin
    if(!aresetn) begin
        s_axi_arready <= 0;
        ar_valid      <= 0;
    end
    else begin

        s_axi_arready <= !ar_valid;

        if(s_axi_arvalid && s_axi_arready) begin
            araddr_reg <= s_axi_araddr;
            ar_valid   <= 1;
        end

        if(s_axi_rvalid && s_axi_rready)
            ar_valid <= 0;

    end
end

////////////////////////////////////////////////////////////
// READ DATA CHANNEL
////////////////////////////////////////////////////////////

always_ff @(posedge aclk) begin
    if(!aresetn) begin
        s_axi_rvalid <= 0;
        s_axi_rresp  <= 0;
        s_axi_rdata  <= 0;
    end
    else begin

        if(ar_valid && !s_axi_rvalid) begin

            s_axi_rdata  <= regfile[araddr_reg[3:2]];
            s_axi_rvalid <= 1;
            s_axi_rresp  <= 2'b00;

        end

        if(s_axi_rvalid && s_axi_rready)
            s_axi_rvalid <= 0;

    end
end

endmodule