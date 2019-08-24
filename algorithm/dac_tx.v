`timescale 1ns / 1ps

module dac_tx(
    //clock and reset
    pcm_clk,
    rst,

    //pcm input and output
    dac_pcm_out_valid,
    dac_pcm_out_ready,
    dac_pcm_out,

    //register access
    clk_2,
    reg_addr,
    reg_rd,
    reg_wr,
    reg_ready,
    reg_writedata,
    reg_readdata,

    dac_signal_len,
    dac_cic_rate,
    dac_run
);
parameter CHANNEL=3;
parameter pcmaw=10;
localparam cicdw=40;

    //clock and reset
    input                       pcm_clk;
    input                       rst;

    //pcm input and output
    output [CHANNEL-1:0]        dac_pcm_out_valid;
    input [CHANNEL-1:0]         dac_pcm_out_ready;
    output [16*CHANNEL-1:0]     dac_pcm_out;

    //register access
    input                       clk_2;
    input [15:0]                reg_addr;
    input                       reg_rd;
    input                       reg_wr;
    output                      reg_ready;
    input [31:0]                reg_writedata;
    output [31:0]               reg_readdata;

    input [pcmaw*CHANNEL-1:0]   dac_signal_len;
    input [4*CHANNEL-1:0]       dac_cic_rate;
    input                       dac_run;

    //internal wire
    wire [CHANNEL-1:0]          pcm_out_valid;
    wire [CHANNEL-1:0]          pcm_cic_in_valid;
    wire [CHANNEL-1:0]          pcm_cic_in_ready;
    wire [16*CHANNEL-1:0]       pcm_cic_in;
    reg                         dac_run_d;
    
    always @(posedge clk_2)
    if (rst)
        dac_run_d <= #1 0;
    else
        dac_run_d <= #1 dac_run;

    source_mem #(
    .CHANNEL                    (CHANNEL),
    .pcmaw                      (pcmaw)
    ) source_mem_inst(
    //clock and reset
    .pcm_clk                    (pcm_clk),
    .rst                        (rst | (dac_run & !dac_run_d)),

    //pcm input and output
    .pcm_out_valid              (pcm_out_valid),
    .pcm_out_ready              (pcm_cic_in_ready & {CHANNEL{dac_run}}),
    .pcm_out                    (pcm_cic_in),

    //register access
    .clk_2                      (clk_2),
    .reg_addr                   (reg_addr),
    .reg_rd                     (reg_rd),
    .reg_wr                     (reg_wr),
    .reg_ready                  (reg_ready),
    .reg_writedata              (reg_writedata),
    .reg_readdata               (reg_readdata),

    .signal_len                 (dac_signal_len)
    );
generate
genvar k;
    for (k=0; k<CHANNEL; k=k+1)
    begin : dac_cic
    wire [cicdw-1:0]            out_data;
    cic_inp cic_inp_inst(
	.clk                        (pcm_clk),
	.clken                      (1'b1),
	.in_data                    (pcm_cic_in[16*k+15:16*k]),
	.in_error                   (2'b0),
	.in_ready                   (pcm_cic_in_ready[k]),
	.in_valid                   (pcm_cic_in_valid[k]),
	.out_data                   (out_data),
	.out_error                  (),
	.out_ready                  (dac_pcm_out_ready[k]),
	.out_valid                  (dac_pcm_out_valid[k]),
	.rate                       (13'd1<<dac_cic_rate[4*k+3:4*k]),
	.reset_n                    (!rst & dac_run)
	);
	assign dac_pcm_out[16*k+15:16*k] = out_data >> (dac_cic_rate[4*k+3:4*k] << 1);
	assign pcm_cic_in_valid[k] = pcm_out_valid[k];
    end
endgenerate
endmodule