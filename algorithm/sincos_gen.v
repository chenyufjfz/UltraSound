`timescale 1ns / 1ps

module sincos_gen(
    //clock and reset
    da_clk,
    ad_clk,
    rst,

    //pcm input and output
    sc_iqpcm_valid,
    sc_ipcm_out,
    sc_qpcm_out,
    sc_ad_valid,

    //register access
    clk_2,
    reg_addr,
    reg_rd,
    reg_wr,
    reg_ready,
    reg_writedata,
    reg_readdata,

    //controller
    sc_sin_length,
    sc_cic_rate,
    sc_resync,
    sc_status,
    sc_err
);
parameter pcmaw=11;
parameter FREQ_NUM=5;
parameter AD_RATIO=2;
localparam cicdw=40;

    //clock and reset
    input                           da_clk;
    input                           ad_clk;
    input                           rst;

    //pcm input and output
    output reg                      sc_iqpcm_valid;
    output [16*FREQ_NUM-1:0]        sc_ipcm_out;
    output [16*FREQ_NUM-1:0]        sc_qpcm_out;
    output                          sc_ad_valid;

    //register access
    input                           clk_2;
    input [16:0]                    reg_addr;
    input                           reg_rd;
    input                           reg_wr;
    output reg                      reg_ready;
    input [31:0]                    reg_writedata;
    output [31:0]                   reg_readdata;

    //controller
    input [16*FREQ_NUM-1:0]         sc_sin_length;
    input [4*FREQ_NUM-1:0]          sc_cic_rate;
    input                           sc_resync;
    output [16*FREQ_NUM-1:0]        sc_status;
    output reg                      sc_err;

    //internal
    wire [31:0]                     reg_readdata_i[FREQ_NUM-1 : 0];
    wire [FREQ_NUM-1:0]             ipcm_out_valid;
    wire [FREQ_NUM-1:0]             qpcm_out_valid;
    reg [16*FREQ_NUM-1:0]           sc_sin_length_d;
    reg [4*FREQ_NUM-1:0]            sc_cic_rate_d;
    reg [6:0]                       resync_cnt;
    reg                             resync_cnt0_d;
    reg [1:0]                       ad_cnt, ad_cnt_hit;

    always @(posedge da_clk)
    begin
        sc_sin_length_d <= #1 sc_sin_length;
        sc_cic_rate_d <= #1 sc_cic_rate;
    end

    always @(posedge clk_2 or posedge rst)
    if (rst)
        reg_ready <= #1 0;
    else
        if (reg_wr | reg_rd)
            reg_ready <= #1 !reg_ready;
        else
            reg_ready <= #1 0;

    assign reg_readdata = reg_readdata_i[reg_addr[16:14]];

generate
genvar i;
    for (i=0; i<FREQ_NUM; i=i+1)
    begin : sincos_gen_inst

    wire                            pcm_valid;
    wire                            pcm_ready_i, pcm_ready_q;
    wire [15:0]                     ipcm;
    wire [15:0]                     qpcm;
    wire [cicdw-1:0]                out_ipcm;
    wire [cicdw-1:0]                out_qpcm;

    sincos_mem #(
    .pcmaw                          (pcmaw)
    ) sincos_mem_inst(
    //clock and reset
    .da_clk                         (da_clk),
    .rst                            (rst),

    //pcm input and output
    .pcm_out_valid                  (pcm_valid),
    .pcm_out_ready                  (pcm_ready_i & pcm_ready_q),
    .ipcm_out                       (ipcm),
    .qpcm_out                       (qpcm),

    //register access
    .clk_2                          (clk_2),
    .reg_addr                       (reg_addr[pcmaw-1:0]),
    .reg_rd                         (reg_rd && reg_addr[16:14]==i),
    .reg_wr                         (reg_wr && reg_addr[16:14]==i),
    .reg_ready                      (),
    .reg_writedata                  (reg_writedata),
    .reg_readdata                   (reg_readdata_i[i]),

    .sin_length                     (sc_sin_length_d[16*i+pcmaw:16*i]),
    .resync                         (sc_resync),
    .status                         (sc_status[16*i+15:16*i])
    );

    cic_inp cic_inp_ipcm(
	.clk                            (da_clk),
	.clken                          (1'b1),
	.in_data                        (ipcm),
	.in_error                       (2'b0),
	.in_ready                       (pcm_ready_i),
	.in_valid                       (pcm_valid),
	.out_data                       (out_ipcm),
	.out_error                      (),
	.out_ready                      (1'b1),
	.out_valid                      (ipcm_out_valid[i]),
	.rate                           (13'd1<<sc_cic_rate_d[4*i+3:4*i]),
	.reset_n                        (!rst & !sc_resync)
	);
	assign sc_ipcm_out[16*i+15:16*i] = out_ipcm >> (sc_cic_rate_d[4*i+3:4*i] << 1);

	cic_inp cic_inp_qpcm(
	.clk                            (da_clk),
	.clken                          (1'b1),
	.in_data                        (qpcm),
	.in_error                       (2'b0),
	.in_ready                       (pcm_ready_q),
	.in_valid                       (pcm_valid),
	.out_data                       (out_qpcm),
	.out_error                      (),
	.out_ready                      (1'b1),
	.out_valid                      (qpcm_out_valid[i]),
	.rate                           (13'd1<<sc_cic_rate_d[4*i+3:4*i]),
	.reset_n                        (!rst & !sc_resync)
	);
	assign sc_qpcm_out[16*i+15:16*i] = out_qpcm >> (sc_cic_rate_d[4*i+3:4*i] << 1);
    end
endgenerate

    always @(posedge ad_clk)
    if (rst || sc_resync)
    begin
        resync_cnt <= #1 127;
        sc_iqpcm_valid <= #1 0;
    end
    else
    begin
        resync_cnt <= #1 (resync_cnt != 0) ? resync_cnt - 1'b1 : 0;
        if (resync_cnt == 0 && ipcm_out_valid == {FREQ_NUM{1'b1}} && qpcm_out_valid == {FREQ_NUM{1'b1}})
            sc_iqpcm_valid <= #1 1;
    end
    
    always @(posedge da_clk)
        resync_cnt0_d <= #1 resync_cnt[0];
        
    always @(posedge da_clk)
    if (rst)
        ad_cnt <= #1 0;
    else
        ad_cnt <= #1 (ad_cnt != AD_RATIO - 1) ? ad_cnt + 1'b1 : 0;
    
    always @(posedge da_clk)
    if (rst  || sc_resync)
        ad_cnt_hit <= #1 0;
    else
        if (resync_cnt0_d != resync_cnt[0])
            ad_cnt_hit <= #1 ad_cnt;
            
    assign sc_ad_valid = sc_iqpcm_valid && (ad_cnt == ad_cnt_hit);

    always @(posedge da_clk)
    if (rst || sc_resync)
        sc_err <= #1 1'b0;
    else
        if (sc_iqpcm_valid && (ipcm_out_valid != {FREQ_NUM{1'b1}} || qpcm_out_valid != {FREQ_NUM{1'b1}}))
            sc_err <= #1 1'b1;
endmodule