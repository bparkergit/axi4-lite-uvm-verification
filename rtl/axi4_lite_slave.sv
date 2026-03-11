module axi4_lite_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    axi_if.DUT axi
);

//////////////////////////////////////////////
// Register File
//////////////////////////////////////////////

logic [DATA_WIDTH-1:0] regfile [0:3];

//////////////////////////////////////////////
// Write Channel State
//////////////////////////////////////////////

logic [ADDR_WIDTH-1:0] awaddr_reg;
logic [DATA_WIDTH-1:0] wdata_reg;

logic awaddr_valid;
logic wdata_valid;

//////////////////////////////////////////////
// Read Channel
//////////////////////////////////////////////

logic [ADDR_WIDTH-1:0] araddr_reg;
logic araddr_valid;

//////////////////////////////////////////////
// WRITE ADDRESS CHANNEL
//////////////////////////////////////////////

always_ff @(posedge axi.aclk) begin
    if(!axi.aresetn) begin
        axi.s_axi_awready <= 0;
        awaddr_valid <= 0;
    end
    else begin

        if(!awaddr_valid) begin
            axi.s_axi_awready <= 1;

            if(axi.s_axi_awvalid && axi.s_axi_awready) begin
                awaddr_reg   <= axi.s_axi_awaddr;
                awaddr_valid <= 1;
                axi.s_axi_awready <= 0;
            end
        end

    end
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

        if(!wdata_valid) begin
            axi.s_axi_wready <= 1;

            if(axi.s_axi_wvalid && axi.s_axi_wready) begin
                wdata_reg <= axi.s_axi_wdata;
                wdata_valid <= 1;
                axi.s_axi_wready <= 0;
            end
        end

    end
end

//////////////////////////////////////////////
// WRITE EXECUTION
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

            awaddr_valid <= 0;
            wdata_valid  <= 0;

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

        if(!araddr_valid) begin
            axi.s_axi_arready <= 1;

            if(axi.s_axi_arvalid && axi.s_axi_arready) begin
                araddr_reg   <= axi.s_axi_araddr;
                araddr_valid <= 1;
                axi.s_axi_arready <= 0;
            end
        end

    end
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

            araddr_valid <= 0;

        end

        if(axi.s_axi_rvalid && axi.s_axi_rready)
            axi.s_axi_rvalid <= 0;

    end
end

endmodule