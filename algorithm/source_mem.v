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
    sep,
    signal_len
);
parameter aw=10;

    //clock and reset
    input           pcm_clk;
    input           rst;

    //pcm input and output
    output          pcm_out_valid;
    input           pcm_out_ready;
    output [15:0]   pcm_out;

    //register access
    input [11:0]    sep;
    input [aw-1:0]  signal_len;
    
    //internal reg
    reg [11:0]      
endmodule