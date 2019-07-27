`timescale 1ns / 1ps

module fir_mc
(
    //clock and reset
    pcm_clk,
    clk1,
    rst,

    //pcm input and output
    pcm_in_valid,
    pcm_in_ready,
    pcm_in,
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
    reg_readdata
);
parameter CHANNEL = 8;
parameter FIR_LANE = 4;
parameter acw = 30;
parameter SIMULATION = 1;

    input                           pcm_clk;
    input                           clk1;
    input                           rst;

    //pcm input and output
    input [CHANNEL-1:0]             pcm_in_valid;
    output [CHANNEL-1:0]            pcm_in_ready;
    input [16*CHANNEL-1:0]          pcm_in;
    output [CHANNEL-1:0]            pcm_out_valid;
    input [CHANNEL-1:0]             pcm_out_ready;
    output [16*CHANNEL-1:0]         pcm_out;

    //register access
    input                           clk_2;
    input [7:0]                     reg_addr;
    input                           reg_rd;
    input                           reg_wr;
    output reg                      reg_ready;
    input [31:0]                    reg_writedata;
    output [31:0]                   reg_readdata;

    //internal signal
    wire [FIR_LANE * 32 - 1:0]      param_q;
    wire [FIR_LANE * 8 - 1:0]       param_addr;
    wire [31:0]                     param_readdata;
    reg [3:0]                       pcm_out_shift;
    reg                             bypass;
    reg [7:0]                       down_sample;
    reg [7:0]                       tap_len;

    fir #(
    .FIR_LANE           (FIR_LANE),
    .gen_param_addr     (1),
    .acw                (acw)
    ) fir_inst (
    //clock and reset
    .pcm_clk            (pcm_clk),
    .clk1               (clk1),
    .rst                (rst),
    
    //pcm input and output
    .pcm_in_valid       (pcm_in_valid[0]),
    .pcm_in_ready       (pcm_in_ready[0]),
    .pcm_in             (pcm_in[15:0]),
    .pcm_out_valid      (pcm_out_valid[0]),
    .pcm_out_ready      (pcm_out_ready[0]),
    .pcm_out            (pcm_out[15:0]),

    //fir parameter input
    .param_q            (param_q),
    .param_addr         (param_addr),

    //control
    .pcm_out_shift      (pcm_out_shift),
    .bypass             (bypass),
    .down_sample        (down_sample),
    .tap_len            (tap_len)
    );
generate
    genvar k;
    for (k=0; k<CHANNEL; k=k+1)
    begin : fir_create
    fir #(
    .FIR_LANE           (FIR_LANE),
    .gen_param_addr     (0),
    .acw                (acw)
    ) fir_inst (
    //clock and reset
    .pcm_clk            (pcm_clk),
    .clk1               (clk1),
    .rst                (rst),
    
    //pcm input and output
    .pcm_in_valid       (pcm_in_valid[k]),
    .pcm_in_ready       (pcm_in_ready[k]),
    .pcm_in             (pcm_in[16*k+15:16*k]),
    .pcm_out_valid      (pcm_out_valid[k]),
    .pcm_out_ready      (pcm_out_ready[k]),
    .pcm_out            (pcm_out[16*k+15:16*k]),

    //fir parameter input
    .param_q            (param_q),
    .param_addr         (),

    //control
    .pcm_out_shift      (pcm_out_shift),
    .bypass             (bypass),
    .down_sample        (down_sample),
    .tap_len            (tap_len)
    );
    end
endgenerate

generate
    genvar i;
    for (i=0; i<FIR_LANE; i=i+1)
    begin : param_ram_create
        rowo_dpram #(
        .dw             (32),
        .aw             (8),
        .pipeline       (2),
        .SIMULATION     (SIMULATION)
        ) param_ram(
        .data           (reg_writedata),	    
	    .wraddress      (reg_addr[7:0]),
	    .wrclock        (clk_2),
	    .wren           (reg_wr),
	    .rdaddress      (param_addr[8*i+7:8*i]),
	    .rdclock        (clk1),
	    .q              (param_q[32*i+31:32*i])
        );
    end
endgenerate

    always @(posedge clk_2)
    if (rst)
        reg_ready <= #1 0;
    else
        if (reg_wr | reg_rd)
            reg_ready <= #1 !reg_ready;
    
    always @(posedge clk_2)
    if (rst)
    begin
        bypass <= #1 1;
        down_sample <= #1 1;
        tap_len <= #1 0;
        pcm_out_shift <= #1 9;
    end
    else
        if (reg_wr && reg_addr == 8'hff)
            {bypass, pcm_out_shift, tap_len, down_sample} <= #1 reg_writedata[20:0];
            
    assign reg_readdata = (reg_addr == 8'hff) ? {bypass, pcm_out_shift, tap_len, down_sample} : param_readdata;
    
    generic_spram #(
        .dw             (32),
        .aw             (8),
        .SIMULATION     (SIMULATION)
    )  param_backup(
        .clk            (clk_2),
        .re             (reg_rd),
        .we             (reg_wr),
        .addr           (reg_addr),
        .q              (param_readdata),
        .data           (reg_writedata)
    );
endmodule