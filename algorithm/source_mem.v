`timescale 1ns / 1ps

module source_mem(
    //clock and reset
    pcm_clk,
    rst,

    //pcm input and output
    pcm_out_valid,
    pcm_out_ready,
    pcm_out,

    //register access
    clk_2,
    reg_addr,
    reg_rd,
    reg_wr,
    reg_ready,
    reg_writedata,
    reg_readdata,
    
    signal_len
);
parameter CHANNEL=3;
parameter pcmaw=10;

    //clock and reset
    input                       pcm_clk;
    input                       rst;

    //pcm input and output
    output [CHANNEL-1:0]        pcm_out_valid;
    input [CHANNEL-1:0]         pcm_out_ready;
    output reg [16*CHANNEL-1:0] pcm_out;

    //register access
    input                       clk_2;
    input [15:0]                reg_addr;
    input                       reg_rd;
    input                       reg_wr;
    output reg                  reg_ready;
    input [31:0]                reg_writedata;
    output [31:0]               reg_readdata;
    input [pcmaw*CHANNEL-1:0]   signal_len;
    
    //internal reg    
    reg [pcmaw-1:0]             pcm_addr[CHANNEL-1:0];
    wire [31:0]                 reg_readdata_dac[CHANNEL-1:0];
    
    always @(posedge clk_2)
    if (rst)
        reg_ready <= #1 0;
    else
        if (reg_wr | reg_rd)
            reg_ready <= #1 !reg_ready;
        else
            reg_ready <= #1 0;
    
    assign reg_readdata = (pcmaw==13 || reg_addr[11:pcmaw-1]==0) ? reg_readdata_dac[reg_addr[15:12]] : 0;
generate
    genvar k;
    for (k=0; k < CHANNEL; k=k+1)
    begin : dac_mem
        wire wren;
        wire [15:0]             pcm_q;
        
        assign wren = (reg_addr[15:12] == k && reg_wr && (pcmaw==13 || reg_addr[11:pcmaw-1]==0));
        assign pcm_out_valid[k] = !rst && signal_len[pcmaw*k+pcmaw-1:pcmaw*k];
        
        generic_dpram #(
        .adw            (16),
        .aaw            (pcmaw),
        .bdw            (32),
        .pipeline       (1)
        ) pcm_mem(
        .address_a      (pcm_addr[k]),
	    .address_b      (reg_addr[pcmaw-2:0]),
	    .clock_a        (pcm_clk),
	    .clock_b        (clk_2),
	    .data_a         (),
	    .data_b         (reg_writedata),
	    .rden_a         (pcm_out_ready[k]),
	    .rden_b         (1'b1),
	    .wren_a         (1'b0),
	    .wren_b         (wren),
	    .q_a            (pcm_q),
	    .q_b            (reg_readdata_dac[k])
        );
        
        always @(posedge pcm_clk)
        if (rst)
        begin
            pcm_addr[k] <= #1 0;
            pcm_out[16*k+15:16*k] <= #1 0;
        end
        else
            if (pcm_out_ready[k] && signal_len[pcmaw*k+pcmaw-1:pcmaw*k])
            begin
                pcm_out[16*k+15:16*k] <= #1 pcm_q;
                pcm_addr[k] <= #1 (pcm_addr[k] + 1'b1 == signal_len[pcmaw*k+pcmaw-1:pcmaw*k]) ? 0 : pcm_addr[k] + 1'b1 ;
            end
    end    
endgenerate
endmodule