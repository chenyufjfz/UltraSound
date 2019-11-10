`timescale 1ns / 1ps

module mix_freq2_mc(
    //reset and clock
    rst,
    clk1,
    clk_2,
    ad_clk,

    //pcm input
    ad_pcm_in_valid,
    ad_pcm_in,
    da_lb_pcm_in_valid,
    da_lb_pcm_in,

    //iq pcm input
    ipcm_in,
    qpcm_in,
    ad_valid,
    iqpcm_valid,

    mf_ipcm_acc_out,
    mf_qpcm_acc_out,

    //controller
    mf_iq_read,
    choose_lb,
    acc_shift,
    cycle_num,
    err_clr,
    err
);
parameter FREQ_NUM = 6;
parameter CHANNEL = 8;

    //reset and clock
    input                       rst;
    input                       clk1;
    input                       clk_2;
    input                       ad_clk;

    //pcm input
    input [CHANNEL-1:0]         ad_pcm_in_valid;
    input [16*CHANNEL-1:0]      ad_pcm_in;
    input [CHANNEL-1:0]         da_lb_pcm_in_valid;
    input [16*CHANNEL-1:0]      da_lb_pcm_in;

    //iq pcm input
    input [16*FREQ_NUM-1:0]     ipcm_in;
    input [16*FREQ_NUM-1:0]     qpcm_in;
    input                       iqpcm_valid;
    input                       ad_valid;
    output reg [32*CHANNEL*FREQ_NUM-1:0]    mf_ipcm_acc_out;
    output reg [32*CHANNEL*FREQ_NUM-1:0]    mf_qpcm_acc_out;

    //controller access
    input                       mf_iq_read;
    input [FREQ_NUM-1:0]        choose_lb;
    input [4*FREQ_NUM-1:0]      acc_shift;
    input [24*FREQ_NUM-1:0]     cycle_num;
    input [FREQ_NUM-1:0]        err_clr;
    output reg [FREQ_NUM-1:0]   err;
    
    //internal wire
    wire [32*CHANNEL*FREQ_NUM-1:0]  ipcm_acc_out, qpcm_acc_out;

generate
genvar j, m;
    for (m=0; m<FREQ_NUM; m=m+1)
    begin : mix_mf
        wire [CHANNEL*2-1:0]    cerr;
        for (j=0; j<CHANNEL; j=j+1)
        begin : mix_mc
            mix_freq2 mix_freq2_inst(
                //reset and clock
                .rst                (rst),
                .clk1               (clk1),
                .ad_clk             (ad_clk),

                //pcm input
                .ad_pcm_in_valid    (ad_pcm_in_valid[j]),
                .ad_pcm_in          (ad_pcm_in[16*j+15:16*j]),
                .da_lb_pcm_in_valid (da_lb_pcm_in_valid[j]),
                .da_lb_pcm_in       (da_lb_pcm_in[16*j+15:16*j]),

                //iq pcm input
                .ipcm_in            (ipcm_in[16*m+15:16*m]),
                .qpcm_in            (qpcm_in[16*m+15:16*m]),
                .iqpcm_valid		(iqpcm_valid),
                .ad_valid           (ad_valid),
                .ipcm_acc_out       (ipcm_acc_out[32*(m*CHANNEL+j)+31 : 32*(m*CHANNEL+j)]),
                .qpcm_acc_out       (qpcm_acc_out[32*(m*CHANNEL+j)+31 : 32*(m*CHANNEL+j)]),

                //register access
                .choose_lb          (choose_lb[m]),
                .acc_shift          (acc_shift[4*m+3:4*m]),
                .cycle_num          (cycle_num[24*m+23:24*m]),
                .err_clr            (err_clr[m]),
                .err                (cerr[2*j+1:2*j])
            );
        end
        always @(posedge clk1)
        if (err_clr[m] | rst)
            err[m] <= #1 1'b0;
        else
            if (cerr)
                err[m] <= #1 1'b1;
    end
endgenerate

    always @(posedge clk_2)
    if (mf_iq_read)
    begin
        mf_ipcm_acc_out <= #1 ipcm_acc_out;
        mf_qpcm_acc_out <= #1 qpcm_acc_out;
    end

endmodule