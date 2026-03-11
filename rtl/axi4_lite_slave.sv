module axi4_lite_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    axi_if.DUT axi
);

logic [DATA_WIDTH-1:0] regfile [0:3];

logic [ADDR_WIDTH-1:0] awaddr_reg;
logic [DATA_WIDTH-1:0] wdata_reg;
logic [ADDR_WIDTH-1:0] araddr_reg;

logic awaddr_valid, awaddr_valid_next;
logic wdata_valid,  wdata_valid_next;
logic araddr_valid, araddr_valid_next;

//////////////////////////////////////////////
// WRITE ADDRESS CHANNEL
//////////////////////////////////////////////

always_ff @(posedge axi.aclk) begin
    if(!axi.aresetn) begin
        axi.s_axi_awready <= 0;
        awaddr_valid <= 0;
    end
    else begin
        axi.s_axi_awready <= !awaddr_valid;
        awaddr_valid <= awaddr_valid_next;

        if(axi.s_axi_awvalid && axi.s_axi_awready)
            awaddr_reg <= axi.s_axi_awaddr;
    end
end

always_comb begin
    awaddr_valid_next = awaddr_valid;

    if(axi.s_axi_awvalid && axi.s_axi_awready)
        awaddr_valid_next = 1;

    if(awaddr_valid && wdata_valid && axi.s_axi_bready && axi.s_axi_bvalid)
        awaddr_valid_next = 0;
end

//////////////////////////////////////////////
// WRITE DATA CHANNEL
//////////////////////////////////////////////

always_ff @(posedge axi.aclk) begin
    if(!axi.aresetn) begin
        axi.s_axi_wready <= 0;
        wdata_valid <= 0;
    end
    else begin
        axi.s_axi_wready <= !wdata_valid;
        wdata_valid <= wdata_valid_next;

        if(axi.s_axi_wvalid && axi.s_axi_wready)
            wdata_reg <= axi.s_axi_wdata;
    end
end

always_comb begin
    wdata_valid_next = wdata_valid;

    if(axi.s_axi_wvalid && axi.s_axi_wready)
        wdata_valid_next = 1;

    if(awaddr_valid && wdata_valid && axi.s_axi_bready && axi.s_axi_bvalid)
        wdata_valid_next = 0;
end

//////////////////////////////////////////////
// WRITE RESPONSE
//////////////////////////////////////////////

always_ff @(posedge axi.aclk) begin
    if(!axi.aresetn) begin
        axi.s_axi_bvalid <= 0;
        axi.s_axi_bresp  <= 0;
    end
    else begin

        if(awaddr_valid && wdata_valid && !axi.s_axi_bvalid) begin
            regfile[awaddr_reg[3:2]] <= wdata_reg;
            axi.s_axi_bvalid <= 1;
            axi.s_axi_bresp  <= 2'b00;
        end

        if(axi.s_axi_bvalid && axi.s_axi_bready)
            axi.s_axi_bvalid <= 0;

    end
end

//////////////////////////////////////////////
// READ ADDRESS CHANNEL
//////////////////////////////////////////////

always_ff @(posedge axi.aclk) begin
    if(!axi.aresetn) begin
        axi.s_axi_arready <= 0;
        araddr_valid <= 0;
    end
    else begin
        axi.s_axi_arready <= !araddr_valid;
        araddr_valid <= araddr_valid_next;

        if(axi.s_axi_arvalid && axi.s_axi_arready)
            araddr_reg <= axi.s_axi_araddr;
    end
end

always_comb begin
    araddr_valid_next = araddr_valid;

    if(axi.s_axi_arvalid && axi.s_axi_arready)
        araddr_valid_next = 1;

    if(araddr_valid && axi.s_axi_rready && axi.s_axi_rvalid)
        araddr_valid_next = 0;
end

//////////////////////////////////////////////
// READ DATA CHANNEL
//////////////////////////////////////////////

always_ff @(posedge axi.aclk) begin
    if(!axi.aresetn) begin
        axi.s_axi_rvalid <= 0;
        axi.s_axi_rresp  <= 0;
        axi.s_axi_rdata  <= 0;
    end
    else begin

        if(araddr_valid && !axi.s_axi_rvalid) begin
            axi.s_axi_rdata  <= regfile[araddr_reg[3:2]];
            axi.s_axi_rvalid <= 1;
            axi.s_axi_rresp  <= 2'b00;
        end

        if(axi.s_axi_rvalid && axi.s_axi_rready)
            axi.s_axi_rvalid <= 0;

    end
end

endmodule