module axi4_lite_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    axi_if.DUT axi
);

logic [DATA_WIDTH-1:0] regfile [0:3];

logic write_en;
logic read_en;

logic [ADDR_WIDTH-1:0] awaddr_reg;
logic [ADDR_WIDTH-1:0] araddr_reg;

assign write_en =
    axi.s_axi_awvalid &&
    axi.s_axi_wvalid  &&
    axi.s_axi_awready &&
    axi.s_axi_wready;

assign read_en =
    axi.s_axi_arvalid &&
    axi.s_axi_arready;

//////////////////////////////////////////////
// WRITE CHANNEL
//////////////////////////////////////////////

always_ff @(posedge axi.aclk) begin
    if(!axi.aresetn) begin
        axi.s_axi_awready <= 0;
        axi.s_axi_wready  <= 0;
        axi.s_axi_bvalid  <= 0;
        axi.s_axi_bresp   <= 0;
    end
    else begin

        // Accept address
        if(!axi.s_axi_awready && axi.s_axi_awvalid)
            axi.s_axi_awready <= 1;
        else
            axi.s_axi_awready <= 0;

        // Accept data
        if(!axi.s_axi_wready && axi.s_axi_wvalid)
            axi.s_axi_wready <= 1;
        else
            axi.s_axi_wready <= 0;

        // Write operation
        if(write_en) begin
            awaddr_reg <= axi.s_axi_awaddr;

            regfile[axi.s_axi_awaddr[3:2]] <= axi.s_axi_wdata;

            axi.s_axi_bvalid <= 1;
            axi.s_axi_bresp  <= 2'b00; // OKAY
        end

        if(axi.s_axi_bvalid && axi.s_axi_bready)
            axi.s_axi_bvalid <= 0;

    end
end

//////////////////////////////////////////////
// READ CHANNEL
//////////////////////////////////////////////

always_ff @(posedge axi.aclk) begin
    if(!axi.aresetn) begin
        axi.s_axi_arready <= 0;
        axi.s_axi_rvalid  <= 0;
        axi.s_axi_rresp   <= 0;
        axi.s_axi_rdata   <= 0;
    end
    else begin

        if(!axi.s_axi_arready && axi.s_axi_arvalid)
            axi.s_axi_arready <= 1;
        else
            axi.s_axi_arready <= 0;

        if(read_en) begin
            araddr_reg <= axi.s_axi_araddr;

            axi.s_axi_rdata <= regfile[axi.s_axi_araddr[3:2]];
            axi.s_axi_rvalid <= 1;
            axi.s_axi_rresp  <= 2'b00;
        end

        if(axi.s_axi_rvalid && axi.s_axi_rready)
            axi.s_axi_rvalid <= 0;

    end
end

endmodule