`timescale 1ns / 1ps

module sdio_slave(
    //clock and reset
    clk,
    rst,
    
    //reg access
    sdio_addr,
    sdio_writedata,
    sdio_rd,
    sdio_wr,
    sdio_readdata,
    
    //sdio access
    sdio_miso,
    sdio_mosi,
    sdio_sck
);
parameter AW = 8;
localparam [1:0]
    STATE_IDLE = 2'd0,
    STATE_WRITE = 2'd1,
    STATE_READ = 2'd2,
    STATE_FINISH = 2'd3;
    
    input                   clk;
    input                   rst;

    //reg access
    output [AW-1:0]         sdio_addr;
    output [31:0]           sdio_writedata;
    output                  sdio_rd;
    output                  sdio_wr;
    input [31:0]            sdio_readdata;
    
    //sdio access
    output                  sdio_miso;
    input                   sdio_mosi;
    input                   sdio_sck;
    
    //internal reg
    reg [33+AW: 0]          rx_data;
    reg [33: 0]             tx_data;
    reg                     sdio_rd_p;
    reg                     sdio_wr_p;
    reg                     sdio_sck_p, sdio_sck_pp;
    reg [1:0]               rx_state;
    wire                    tx_valid;
    wire                    rx_valid;
    
    assign tx_valid = sdio_sck_p & !sdio_sck_pp;
    assign rx_valid = !sdio_sck_p & sdio_sck_pp;
    assign sdio_miso = tx_data[33];
    
    always @(posedge clk or negedge rst)
    if (!rst)
    begin
        sdio_sck_p <= #1 1'b0;
        sdio_sck_pp <= #1 1'b0;
        sdio_wr_p <= #1 1'b0;
        sdio_rd_p <= #1 1'b0;
    end
    else
    begin
        sdio_sck_p <= #1 sdio_sck;
        sdio_sck_pp <= #1 sdio_sck_p;
        sdio_wr_p <= #1 sdio_wr;
        sdio_rd_p <= #1 sdio_rd;
    end
    
    always @(posedge clk or negedge rst)
    if (!rst)
        tx_data <= #1 34'h0;
    else
        if (sdio_wr_p)
            tx_data <= #1 34'h100000000;
        else
            if (sdio_rd_p)
                tx_data <= #1 {2'd1, sdio_readdata};
            else
                if (tx_valid)
                    tx_data <= #1 {tx_data[32:0], 1'b0};    
                
    always @(posedge clk or negedge rst)
    if (!rst)
        rx_data <= #1 {(34+AW){1'b0}};
    else
        if (rx_state == STATE_FINISH)
            rx_data <= #1 {(34+AW){1'b0}};
        else
            if (rx_valid)
                rx_data <= #1 {rx_data[32+AW:0], sdio_mosi};
        
    always @(posedge clk or negedge rst)
    if (!rst)
        rx_state <= #1 STATE_IDLE;
    else
    if (rx_valid)
    begin
        case (rx_state)
        STATE_IDLE: rx_state <= #1 (rx_data[1:0] == 2'd2) ? STATE_READ :
                                (rx_data[1:0] == 2'd3) ? STATE_WRITE :
                                STATE_IDLE;
        STATE_READ: rx_state <= #1 (rx_data[AW+1] == 1'b1) ? STATE_FINISH : STATE_READ;
        STATE_WRITE: rx_state <= #1 (rx_data[33+AW] == 1'b1) ? STATE_FINISH : STATE_WRITE;
        STATE_FINISH: rx_state <= #1 STATE_IDLE;
        endcase
    end
    
    assign sdio_addr = (rx_state == STATE_READ) ? rx_data[AW-1:0] : rx_data[31+AW:32];
    assign sdio_rd = (rx_state == STATE_READ && rx_data[AW+1] == 1'b1 && rx_valid);
    assign sdio_wr = (rx_state == STATE_WRITE && rx_data[33+AW] == 1'b1 && rx_valid);
    assign sdio_writedata = rx_data[31:0];
endmodule