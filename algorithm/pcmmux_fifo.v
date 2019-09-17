`timescale 1ns / 1ps

module pcmmux_fifo(
    //clock and reset
    pcm_in_clk,
    pcm_out_clk,
    rst,

    //pcm input and output
    pcm_in_valid,
    pcm_in_ready,
    pcm_in,
    pcm_out_valid,
    pcm_out_ready,
    pcm_out,

    //register access
    pcm_channel_choose,
    pcm_available,
    pcm_capture_sep
);
parameter CHANNEL=3;
parameter pcmaw=9;

    //clock and reset
    input                       pcm_in_clk;
    input                       pcm_out_clk;
    input                       rst;

    //pcm input and output
    input [CHANNEL-1:0]         pcm_in_valid;
    output [CHANNEL-1:0]        pcm_in_ready;
    input [16*CHANNEL-1:0]      pcm_in;
    output reg                  pcm_out_valid;
    input                       pcm_out_ready;
    output reg [15:0]           pcm_out;

    //register access
    input [7:0]                 pcm_channel_choose;
    output [pcmaw-1:0]          pcm_available;
    input [7:0]                 pcm_capture_sep;

    //internal wire & reg    
    wire [15:0]                 pcm_mux_in[CHANNEL-1:0];
    reg [7:0]                   capture_idx;
    reg [pcmaw-1:0]             pcm_write_addr;

generate
    genvar k;
    for (k=0; k<CHANNEL; k=k+1)
    begin : assign_pcm_mux
        assign pcm_mux_in[k] = pcm_in[16*k+15:16*k];
    end
endgenerate
    
generate
if (pcmaw == 1)
begin
    reg                 pcm_write_addr_d;
    reg [15:0]          pcm_mux_out;
    
    always @(posedge pcm_in_clk)
    if (pcm_in_valid[pcm_channel_choose] && pcm_channel_choose < CHANNEL && capture_idx == 0)
        pcm_mux_out <= #1 pcm_mux_in[pcm_channel_choose];
            
    always @(posedge pcm_out_clk)        
    if (rst)
        pcm_write_addr_d <= #1 0;
    else
        pcm_write_addr_d <= #1 pcm_write_addr;
    
    always @(posedge pcm_out_clk)
    if (pcm_write_addr!=pcm_write_addr_d)
        pcm_out <= #1 pcm_mux_out;
    
    always @(posedge pcm_out_clk)
    if (rst)
        pcm_out_valid <= #1 0;
    else
        if (pcm_write_addr!=pcm_write_addr_d)
            pcm_out_valid <= #1 1'b1;
        else
            if (pcm_out_ready)
                pcm_out_valid <= #1 1'b0;
            
    assign pcm_available = pcm_out_valid;
    
    always @(posedge pcm_in_clk)
    if (rst)
        pcm_write_addr <= #1 0;
    else
    if (pcm_in_valid[pcm_channel_choose] && pcm_channel_choose < CHANNEL && (capture_idx == 0))
        pcm_write_addr <= #1 pcm_write_addr + 1'b1;
end
else
begin
    reg [pcmaw-1:0]             pcm_read_addr;
    wire [15:0]                 pcm_mux_out;
    wire                        pcm_out_valid_pp;
    reg                         pcm_out_valid_p;
    
    rowo_dpram #(
    .rdw            (16),
    .wdw            (16),
    .raw            (pcmaw)
    ) rowo_dpram_inst(
    .data           (pcm_mux_in[pcm_channel_choose]),
	.rdaddress      (pcm_read_addr),
	.rdclock        (pcm_out_clk),
	.wraddress      (pcm_write_addr),
	.wrclock        (pcm_in_clk),
	.rden           (pcm_out_valid_pp && (pcm_out_ready || !pcm_out_valid_p)),
	.wren           (pcm_in_valid[pcm_channel_choose] && pcm_channel_choose < CHANNEL && capture_idx == 0),
	.q              (pcm_mux_out)
    );
    
    always @(posedge pcm_out_clk)
    if (pcm_out_valid_p && (pcm_out_ready || !pcm_out_valid))
        pcm_out <= #1 pcm_mux_out;
        
    always @(posedge pcm_out_clk)
    if (rst)
        pcm_out_valid <= #1 1'b0;
    else
    if (pcm_out_ready || !pcm_out_valid)
        pcm_out_valid <= #1 pcm_out_valid_p;
                
    always @(posedge pcm_out_clk)
    if (rst)
        pcm_read_addr <= #1 0;
    else
        if (pcm_out_valid_pp && (pcm_out_ready || !pcm_out_valid_p))
            pcm_read_addr <= #1 pcm_read_addr + 1'b1;
    
    always @(posedge pcm_out_clk)
    if (rst)
        pcm_out_valid_p <= #1 1'b0;        
    else
    if (pcm_out_ready || !pcm_out_valid_p)
        pcm_out_valid_p <= #1 pcm_out_valid_pp;
                    
    assign pcm_available = pcm_write_addr - pcm_read_addr;
    assign pcm_out_valid_pp = (pcm_read_addr!=pcm_write_addr);

    always @(posedge pcm_in_clk)
    if (rst)
        pcm_write_addr <= #1 0;
    else
    if (pcm_in_valid[pcm_channel_choose] && pcm_channel_choose < CHANNEL && (capture_idx == 0) && pcm_write_addr+1'b1 != pcm_read_addr)
        pcm_write_addr <= #1 pcm_write_addr + 1'b1;
end    
endgenerate
    
    always @(posedge pcm_in_clk)
    if (rst)
        capture_idx <= #1 0;
    else
        if (pcm_in_valid[pcm_channel_choose] && pcm_channel_choose < CHANNEL)
            capture_idx <= #1 (capture_idx == pcm_capture_sep) ? 0 : capture_idx + 1'b1;

    assign pcm_in_ready = {CHANNEL{1'b1}}; 
endmodule