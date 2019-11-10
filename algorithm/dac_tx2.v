`timescale 1ns / 1ps

module dac_tx2(
    //reset and clock
    rst,
    clk1,
    da_clk,

    //iq pcm input
    ipcm_in,
    qpcm_in,
    iqpcm_valid,

    //da pcm output
    dac_pcm_out_valid,
    dac_pcm_out,

    //controller input
    cos_sita,
    sin_sita,
    choose,
    err_clr,
    err
);
parameter CHANNEL = 8;
parameter FREQ_NUM = 6;
parameter MIX_NUM = 3;
parameter sita_w = 16;

    //reset and clock
    input                               rst;
    input                               clk1;
    input                               da_clk;
                                        
    //iq pcm input                      
    input [16*FREQ_NUM-1:0]             ipcm_in;
    input [16*FREQ_NUM-1:0]             qpcm_in;
    input                               iqpcm_valid;

    //da pcm output
    output [CHANNEL-1:0]                dac_pcm_out_valid;
    output [16*CHANNEL-1:0]             dac_pcm_out;

    //controller input
    input [sita_w*MIX_NUM*CHANNEL-1:0]  cos_sita, sin_sita;
    input [4*MIX_NUM*CHANNEL-1:0]       choose;
    input [CHANNEL-1:0]                 err_clr;
    output [CHANNEL-1:0]                err;
    
generate
genvar i;
for (i=0; i<CHANNEL; i=i+1)
begin : tx_mixer
    tx_mix #(
    .FREQ_NUM                           (FREQ_NUM),
    .MIX_NUM                            (MIX_NUM),
    .sita_w                             (sita_w)
    ) tx_mix_inst(
    //reset and clock
    .rst                                (rst),
    .clk1                               (clk1),
    .da_clk                             (da_clk),
                                        
    //iq pcm input                      
    .ipcm_in                            (ipcm_in),
    .qpcm_in                            (qpcm_in),
    .iqpcm_valid                        (iqpcm_valid),

    //da pcm output
    .mix_pcm_out                        (dac_pcm_out[16*i+15:16*i]),
    .mix_pcm_out_valid                  (dac_pcm_out_valid[i]),

    //controller input
    .cos_sita                           (cos_sita[sita_w*MIX_NUM*(i+1)-1:sita_w*MIX_NUM*i]),
    .sin_sita                           (sin_sita[sita_w*MIX_NUM*(i+1)-1:sita_w*MIX_NUM*i]),
    .choose                             (choose[4*MIX_NUM*(i+1)-1:4*MIX_NUM*i]),
    .err_clr                            (err_clr[i]),
    .err                                (err[i])
    );
end
endgenerate
endmodule