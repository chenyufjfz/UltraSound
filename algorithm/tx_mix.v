`timescale 1ns / 1ps

module tx_mix(
    //reset and clock
    rst,
    clk1,
    da_clk,

    //iq pcm input
    ipcm_in,
    qpcm_in,
    iqpcm_valid,

    //da pcm output
    mix_pcm_out,
    mix_pcm_out_valid,

    //controller input
    cos_sita,
    sin_sita,
    choose,
    err_clr,
    err
);
parameter FREQ_NUM = 6;
parameter MIX_NUM = 3;
parameter sita_w = 16;

    //reset and clock
    input                       rst;
    input                       clk1;
    input                       da_clk;

    //iq pcm input
    input [FREQ_NUM*16-1:0]     ipcm_in;
    input [FREQ_NUM*16-1:0]     qpcm_in;
    input                       iqpcm_valid;

    //da pcm output
    output [15:0]               mix_pcm_out;
    output                      mix_pcm_out_valid;

    //controller input
    input [sita_w*MIX_NUM-1:0]  cos_sita, sin_sita;
    input [4*MIX_NUM-1:0]       choose;
    input                       err_clr;
    output reg                  err;

    //internal reg
    wire [15:0]                 ipcm[MIX_NUM-1:0];
    wire [15:0]                 qpcm[MIX_NUM-1:0];
    wire [MIX_NUM-1:0]          ipcm_valid, qpcm_valid;
    reg [31:0]                  mix_in[MIX_NUM-1:0];
    reg [31:0]                  mix_out_r0, mix_out_r1;
    reg [31:0]                  mix_out_0, mix_out_1;
    reg [15:0]                  mix_pcm_out_p;
    reg                         mix_pcm_out_c;
    wire [31:0]                 mix_out; //it is wire
    integer                     i, j;

generate
genvar m;
    for (m=0; m<MIX_NUM; m=m+1)
    begin :mixer
        wire [15+sita_w:0]          mult_result;

        pcmmux_fifo #(
        .CHANNEL            (FREQ_NUM),
        .pcmaw              (1)
        ) ipcm_fifo(
        //clock and reset
        .pcm_in_clk         (da_clk),
        .pcm_out_clk        (clk1),
        .rst                (rst),

        //pcm input and output
        .pcm_in_valid       ({FREQ_NUM{iqpcm_valid}}),
        .pcm_in_ready       (),
        .pcm_in             (ipcm_in),
        .pcm_out_valid      (ipcm_valid[m]),
        .pcm_out_ready      (1'b1),
        .pcm_out            (ipcm[m]),

        //register access
        .pcm_channel_choose ({4'd0,choose[4*m+3:4*m]}),
        .pcm_available      (),
        .pcm_capture_sep    (8'd0)
        );

        pcmmux_fifo #(
        .CHANNEL            (FREQ_NUM),
        .pcmaw              (1)
        ) qpcm_fifo (
        //clock and reset
        .pcm_in_clk         (da_clk),
        .pcm_out_clk        (clk1),
        .rst                (rst),

        //pcm input and output
        .pcm_in_valid       ({FREQ_NUM{iqpcm_valid}}),
        .pcm_in_ready       (),
        .pcm_in             (qpcm_in),
        .pcm_out_valid      (qpcm_valid[m]),
        .pcm_out_ready      (!ipcm_valid[m]),
        .pcm_out            (qpcm[m]),

        //register access
        .pcm_channel_choose ({4'd0,choose[4*m+3:4*m]}),
        .pcm_available      (),
        .pcm_capture_sep    (8'd0)
        );

        mult #(
        .di1                (sita_w),
        .di2                (16),
        .dow                (sita_w+16),
        .pipeline           (2)
        ) mult_inst(
            .clock          (clk1),
        	.dataa          (ipcm_valid[m] ? cos_sita[sita_w*m+sita_w-1:sita_w*m] : sin_sita[sita_w*m+sita_w-1:sita_w*m]),
        	.datab          (ipcm_valid[m] ? ipcm[m] : qpcm[m]),
        	.result         (mult_result)
        );

        always @(posedge clk1)
            mix_in[m] <= #1 ipcm_valid[m] ? mult_result[15+sita_w:sita_w-16] : mix_in[m] + mult_result[15+sita_w:sita_w-16];
    end
endgenerate

    always @(*)
    begin
        mix_out_0 = 0;
        for (i=0; i<MIX_NUM; i=i+2)
            mix_out_0 = mix_out_0 + mix_in[i];
    end

    always @(*)
    begin
        mix_out_1 = 0;
        for (j=1; j<MIX_NUM; j=j+2)
            mix_out_1 = mix_out_1 + mix_in[j];
    end
    
    assign mix_out = mix_out_r0 + mix_out_r1;
    
    always @(posedge clk1)
    if (rst)
    begin
        mix_pcm_out_p <= #1 0;
        mix_out_r0 <= #1 0;
        mix_out_r1 <= #1 0;
        mix_pcm_out_c <= #1 0;
    end
    else
    if (ipcm_valid[0])
    begin
        mix_out_r0 <= #1 mix_out_0;
        mix_out_r1 <= #1 mix_out_1;
    end
    else
    begin
        mix_pcm_out_p <= #1 mix_out[30:15];
        mix_pcm_out_c <= #1 mix_out[14];
    end
        
    assign mix_pcm_out = mix_pcm_out_p + mix_pcm_out_c;
    assign mix_pcm_out_valid = qpcm_valid[0];
    
    always @(posedge clk1)
    if (err_clr || rst)
        err <= #1 1'b0;
    else
        if ((mix_out[31] ^ mix_out[30]) || (mix_out_r0[31] ^ mix_out_r0[30]) || (mix_out_r1[31] ^ mix_out_r1[30]) )
            err <= #1 1'b1;
endmodule
