`timescale 1ns / 1ps

module ram2reg(
    clk,
    rst,
    seq_reg,

    //controller interface
    read_addr,
    read_trigger,

    //AXI interface
    reg_readdata,
    reg_writedata,
    reg_rd,
    reg_wr,
    reg_ready,
    reg_addr
);

parameter REG_NUM=10;
parameter BUF_NUM=80;
localparam aw=$clog2(REG_NUM * BUF_NUM); //$clog2(9)=4
localparam sw=$clog2(REG_NUM);

    input                               clk;
    input                               rst;
    output [REG_NUM * 32-1:0]           seq_reg;

    //controller interface
    input [aw-1:0]                      read_addr;
    input                               read_trigger;

    //AXI interface
    output [31:0]                       reg_readdata;
    input [31:0]                        reg_writedata;
    input                               reg_rd;
    input                               reg_wr;
    output reg                          reg_ready;
    input [aw-1:0]                      reg_addr;
    
    //internal reg
    reg [31:0]                          seq_reg_read[REG_NUM -1 : 0];
    reg [sw-1:0]                        select, select_d;
    reg                                 rd_en;
    wire [31:0]                         read_data;
    
    generate
    genvar i;
    for (i=0; i<REG_NUM; i=i+1)
    begin : seq_reg_connect
        assign seq_reg[32*i+31:32*i] = seq_reg_read[i];
    end
    endgenerate
    
    always @(posedge clk)
    if (rst)
        reg_ready <= #1 0;
    else
        if (reg_rd | reg_wr)
            reg_ready <= #1 !reg_ready;
        else
            reg_ready <= #1 0;
    
    generic_dpram #(
        .adw                (32),
        .aaw                (aw),
        .bdw                (32),
        .pipeline           (1)
    ) sc_mem (
        .address_a          (read_addr + select),
        .address_b          (reg_addr),
        .clock_a            (clk),
        .clock_b            (clk),
        .data_a             (),
        .data_b             (reg_writedata),
        .rden_a             (1'b1),
        .rden_b             (1'b1),
        .wren_a             (1'b0),
        .wren_b             (reg_wr),
        .q_a                (read_data),
        .q_b                (reg_readdata)
    );
    
    always @(posedge clk)
    if (rst)
	    rd_en <= #1 1'b0;
	else
	    if (read_trigger)
	        rd_en <= #1 1'b1;
	    else
	        if (select >= REG_NUM)
	            rd_en <= #1 1'b0;
	            
    always @(posedge clk)
    if (rst)
        select <= #1 0;
    else
        if (rd_en | read_trigger)
            select <= #1 (select >= REG_NUM) ? 0 : select + 1;
        else
            select <= #1 0;
            
    always @(posedge clk)
        select_d <= #1 select;
        
    always @(posedge clk)
    if (rd_en)
        seq_reg_read[select_d] <= #1 read_data;
endmodule