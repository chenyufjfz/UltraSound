`timescale 1ns / 1ps

module sdio_master(
    clk_2,
    rst,
    //AXI reg access
    reg_addr,
    reg_writedata,
    reg_rd_sdio,
    reg_wr_sdio,
    reg_ready_sdio,
    reg_readdata_sdio,

    //sdio access
    sdio_miso,
    sdio_mosi,
    sdio_sck
);
parameter AW = 8;
    input                   clk_2;
    input                   rst;

    //AXI reg access
    input [AW-1:0]          reg_addr;
    input [31:0]            reg_writedata;
    input                   reg_rd_sdio;
    input                   reg_wr_sdio;
    output                  reg_ready_sdio;
    output [31:0]           reg_readdata_sdio;

    //sdio access
    input                   sdio_miso;
    output                  sdio_mosi;
    output reg              sdio_sck;

    //internal reg
    reg [34+AW: 0]          tx_data;
    reg [32: 0]             rx_data;
    reg [5: 0]              clk_counter;
    reg                     sdio_sck_p, sdio_sck_pp;
    reg                     reg_wr_sdio_p;
    reg                     reg_rd_sdio_p;
    reg [7:0]               wait_counter;
    wire                    tx_valid;
    wire                    rx_valid;
    
    assign sdio_mosi = tx_data[34+AW];

    always @(posedge clk_2)
    if (rst)
        clk_counter <= #1 0;
    else
        clk_counter <= #1 (clk_counter == 4) ? 0 : clk_counter + 1;
        
    always @(posedge clk_2)
    if (rst)
        sdio_sck <= #1 1'b0;
    else
        if (clk_counter == 1)
            sdio_sck <= #1 !sdio_sck;
            
    always @(posedge clk_2)
    if (rst)
    begin
        sdio_sck_p <= #1 1'b0;
        sdio_sck_pp <= #1 1'b0;
        reg_wr_sdio_p <= #1 1'b0;
        reg_rd_sdio_p <= #1 1'b0;
    end
    else
    begin
        sdio_sck_p <= #1 sdio_sck;
        sdio_sck_pp <= #1 sdio_sck_p;
        reg_wr_sdio_p <= #1 reg_wr_sdio;
        reg_rd_sdio_p <= #1 reg_rd_sdio;
    end
        
    assign tx_valid = sdio_sck_p & !sdio_sck_pp;
    assign rx_valid = !sdio_sck_p & sdio_sck_pp;
    
    always @(posedge clk_2)
    if (rst)
        tx_data <= #1 {(35+AW){1'b0}};
    else
        if (!reg_wr_sdio_p & reg_wr_sdio)
            tx_data <= #1 {3'd3, reg_addr, reg_writedata};
        else
            if (!reg_rd_sdio_p & reg_rd_sdio)
            tx_data <= #1 {3'd2, reg_addr, 32'd0};
        else
            if (tx_valid)
                tx_data <= #1 {tx_data[33+AW:0], 1'b0};
        
    always @(posedge clk_2)
    if (reg_rd_sdio || reg_wr_sdio)
        rx_data <= rx_valid ? {rx_data[31:0], sdio_miso} : rx_data;
    else
        rx_data <= 33'd0; 
        
    always @(posedge clk_2)
    if (reg_rd_sdio || reg_wr_sdio)
        wait_counter <= rx_valid ? wait_counter + 1 : wait_counter;
    else
        wait_counter <= 0;
    
    assign reg_ready_sdio = (reg_wr_sdio ? rx_data[0] : rx_data[32]) || (wait_counter > 220);
    assign reg_readdata_sdio = rx_data[31:0];
endmodule