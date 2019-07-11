`timescale 1ns / 1ps

module reg_dec_rate(
    //clock & reset
    clk,
    clk_2,
    rst,

    //slave, fast clock domain
    reg_s_addr,
    reg_s_rd,
    reg_s_wr,
    reg_s_ready,
    reg_s_writedata,
    reg_s_readdata,

    //master, slow clock domain
    reg_m_addr,
    reg_m_rd,
    reg_m_wr,
    reg_m_ready,
    reg_m_writedata,
    reg_m_readdata
);
parameter AW=10;

    //clock & reset
    input               clk;
    input               clk_2;
    input               rst;

    //slave, fast clock domain
    input [AW-1:0]      reg_s_addr;
    input               reg_s_rd;
    input               reg_s_wr;
    output reg          reg_s_ready;
    input [31:0]        reg_s_writedata;
    output reg [31:0]   reg_s_readdata;

    //master, slow clock domain
    output reg [AW-1:0] reg_m_addr;
    output reg          reg_m_rd;
    output reg          reg_m_wr;
    input               reg_m_ready;
    output reg [31:0]   reg_m_writedata;
    input [31:0]        reg_m_readdata;

    //internal
    reg                 reg_m_rd_d, reg_m_wr_d;
    reg                 clk_en;
    
    always @(posedge clk_2)
    if (rst)
        reg_m_rd <= #1 1'b0;
    else
    begin
        if (reg_m_ready && reg_m_rd)
            reg_m_rd <= #1 1'b0;
        else
            if (reg_s_rd)
                reg_m_rd <= #1 1'b1;
            else
                reg_m_rd <= #1 1'b0;
    end

    always @(posedge clk_2)
    if (rst)
        reg_m_wr <= #1 1'b0;
    else
    begin
        if (reg_m_ready && reg_m_wr)
            reg_m_wr <= #1 1'b0;
        else
            if (reg_s_wr)
                reg_m_wr <= #1 1'b1;
            else
                reg_m_wr <= #1 1'b0;
    end

    always @(posedge clk_2)
    if (reg_s_wr && !reg_m_wr)
        reg_m_writedata <= #1 reg_s_writedata;
        
    always @(posedge clk_2)
    if (reg_s_wr && !reg_m_wr || reg_s_rd && !reg_m_rd)    
        reg_m_addr <= #1 reg_s_addr;
    

    always @(posedge clk)
    if (rst)
        reg_s_ready <= #1 1'b0;
    else
    begin
        if (clk_en && (reg_m_rd | reg_m_wr) && reg_m_ready)
            reg_s_ready <= #1 1'b1;
        else
            reg_s_ready <= #1 1'b0;
    end
    
    always @(posedge clk_2)
    if (reg_m_rd && reg_m_ready)
        reg_s_readdata <= #1 reg_m_readdata;
        
    always @(posedge clk)
    if (rst)
    begin
        reg_m_rd_d <= #1 1'b0;
        reg_m_wr_d <= #1 1'b0;
    end
    else
    begin
        reg_m_rd_d <= #1 reg_m_rd;
        reg_m_wr_d <= #1 reg_m_wr;
    end
    
    always @(posedge clk)
    if (rst)
        clk_en <= #1 1'b0;
    else
        if (reg_m_rd && !reg_m_rd_d || reg_m_wr && !reg_m_wr_d)
            clk_en <= #1 1'b1;
        else
            clk_en <= #1 !clk_en;
        
endmodule