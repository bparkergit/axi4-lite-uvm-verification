module axi4_lite_slave #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32
)(
    input  logic                     ACLK,
    input  logic                     ARESETn,

    // WRITE ADDRESS CHANNEL
    input  logic [ADDR_WIDTH-1:0]    AWADDR,
    input  logic                     AWVALID,
    output logic                     AWREADY,

    // WRITE DATA CHANNEL
    input  logic [DATA_WIDTH-1:0]    WDATA,
    input  logic [(DATA_WIDTH/8)-1:0] WSTRB,
    input  logic                     WVALID,
    output logic                     WREADY,

    // WRITE RESPONSE CHANNEL
    output logic [1:0]               BRESP,
    output logic                     BVALID,
    input  logic                     BREADY,

    // READ ADDRESS CHANNEL
    input  logic [ADDR_WIDTH-1:0]    ARADDR,
    input  logic                     ARVALID,
    output logic                     ARREADY,

    // READ DATA CHANNEL
    output logic [DATA_WIDTH-1:0]    RDATA,
    output logic [1:0]               RRESP,
    output logic                     RVALID,
    input  logic                     RREADY
);

logic [DATA_WIDTH-1:0] regfile [0:3];

logic [ADDR_WIDTH-1:0] awaddr_reg;
logic [ADDR_WIDTH-1:0] araddr_reg;

logic write_en;
logic read_en;

assign write_en = AWVALID && WVALID && AWREADY && WREADY;
assign read_en  = ARVALID && ARREADY;

always_ff @(posedge ACLK) begin
    if(!ARESETn) begin
        AWREADY <= 0;
        WREADY  <= 0;
        BVALID  <= 0;
        BRESP   <= 0;
    end
    else begin
        AWREADY <= !AWREADY && AWVALID;
        WREADY  <= !WREADY  && WVALID;

        if(write_en) begin
            awaddr_reg <= AWADDR;
            regfile[AWADDR[3:2]] <= WDATA;
            BVALID <= 1;
            BRESP  <= 2'b00; // OKAY
        end
        else if(BVALID && BREADY) begin
            BVALID <= 0;
        end
    end
end

always_ff @(posedge ACLK) begin
    if(!ARESETn) begin
        ARREADY <= 0;
        RVALID  <= 0;
        RRESP   <= 0;
        RDATA   <= 0;
    end
    else begin
        ARREADY <= !ARREADY && ARVALID;

        if(read_en) begin
            araddr_reg <= ARADDR;
            RDATA <= regfile[ARADDR[3:2]];
            RVALID <= 1;
            RRESP  <= 2'b00;
        end
        else if(RVALID && RREADY) begin
            RVALID <= 0;
        end
    end
end

endmodule