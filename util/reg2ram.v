`timescale 1ns / 1ps

module reg2ram(
    clk,
    rst,
    seq_reg,

    //controller interface
    write_addr,
    write_trigger,
    write_rst,
    select,
    write_busy,
    
    //AXI interface
    reg_readdata,
    reg_wr,
    reg_rd,
    reg_ready,
    reg_addr
);
parameter REG_NUM=10;
parameter BUF_NUM=80;
localparam aw=$clog2(REG_NUM * BUF_NUM); //$clog2(9)=4
localparam sw=$clog2(REG_NUM);

    input                               clk;
    input                               rst;
    input [REG_NUM * 32-1:0]            seq_reg;

    //controller interface
    input [aw-1:0]                      write_addr;
    input                               write_trigger;
    input                               write_rst;
    output reg [sw-1:0]                 select;
    output                              write_busy;
    
    //AXI interface
    output [31:0]                       reg_readdata;
    input                               reg_wr;
    input                               reg_rd;
    output reg                          reg_ready;
    input [aw-1:0]                      reg_addr;
    
    //internal wire
    wire [31:0]                         seq_reg_write[REG_NUM -1 : 0];
    wire [31:0]                         write_data;    
    reg                                 wr_en;
    
    assign write_data = seq_reg_write[select];
    assign write_busy = write_trigger | wr_en;
    
    generate
    genvar i;
    for (i=0; i<REG_NUM; i=i+1)
    begin : seq_reg_connect
        assign seq_reg_write[i] = seq_reg[32*i+31:32*i];
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
            
    rowo_dpram #(
    .rdw            (32),
    .raw            (aw),
    .wdw            (32)
    ) reg_buf (
	.data           (write_data),
	.rdaddress      (reg_addr),
	.rden           (1'b1),
	.rdclock        (clk),
	.wraddress      (write_addr + select),
	.wrclock        (clk),
	.wren           (wr_en),
	.q              (reg_readdata)
	);
	
	always @(posedge clk)
	if (rst)
	    wr_en <= #1 1'b0;
	else
	    if (write_trigger)
	        wr_en <= #1 1'b1;
	    else
	        if (select >= REG_NUM -1)
	            wr_en <= #1 1'b0;
    
    always @(posedge clk)
    if (rst)
        select <= #1 0;
    else
        if (wr_en)
            select <= #1 (select >= REG_NUM -1) ? 0 : select + 1;
        else
            select <= #1 0;
                                                        
endmodule