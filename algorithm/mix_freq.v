`timescale 1ns / 1ps

module mix_freq (
    //reset and clock
    rst,
    clk1,
    pcm_clk,

    //pcm input
    ad_pcm_in_valid,
    ad_pcm_in_ready,
    ad_pcm_in,
    da_lb_pcm_in_valid,
    da_lb_pcm_in_ready,
    da_lb_pcm_in,

    //iq pcm input
    ipcm_in,
    qpcm_in,
    iq_next,

    //iq pcm output
    ipcm_dec_out_valid,
    ipcm_dec_out_ready,
    ipcm_dec_out,
    ipcm_acc_out,
    qpcm_dec_out_valid,
    qpcm_dec_out_ready,
    qpcm_dec_out,
    qpcm_acc_out,
    iqpcm_dump_valid,
    iqpcm_dump,

    //register access
    pcm_out_shift,
    choose_lb,
    dec_rate,
    dec_rate2,
    acc_clr,
    acc_shift,
    resync
);

    //reset and clock
    input               rst;
    input               clk1;
    input               pcm_clk;

    //pcm input
    input               ad_pcm_in_valid;
    output              ad_pcm_in_ready;
    input [15:0]        ad_pcm_in;
    input               da_lb_pcm_in_valid;
    output              da_lb_pcm_in_ready;
    input [15:0]        da_lb_pcm_in;


    //iq pcm input
    input [15:0]        ipcm_in;
    input [15:0]        qpcm_in;
    output              iq_next;

    //iq pcm output
    output              ipcm_dec_out_valid;
    input               ipcm_dec_out_ready;
    output [15:0]       ipcm_dec_out;
    output reg [31:0]   ipcm_acc_out;
    output              qpcm_dec_out_valid;
    input               qpcm_dec_out_ready;
    output [15:0]       qpcm_dec_out;
    output reg [31:0]   qpcm_acc_out;
    output              iqpcm_dump_valid;
    output reg [15:0]   iqpcm_dump;

    //register access
    input [3:0]         pcm_out_shift;
    input               choose_lb;
    input [7:0]         dec_rate;
    input [7:0]         dec_rate2;
    input               acc_clr;
    input [3:0]         acc_shift;
    input               resync;

    //internal reg and wire
    wire [15:0]         pcm_in;
    wire                pcm_in_valid;
    reg                 pcm_in_valid_d;
    reg [3:0]           phase;
    wire [31:0]         mult_result;
    reg                 iqpcm_dump_valid0;
    reg                 iqpcm_dump_valid_d;
    reg                 ipcm_out_valid;
    wire                ipcm_out_ready;
    reg [15:0]          ipcm_out;
    reg [39:0]          ipcm_acc;
    reg                 qpcm_out_valid;
    wire                qpcm_out_ready;
    reg [15:0]          qpcm_out;
    reg [39:0]          qpcm_acc;
    reg [31:0]          acc_in;

    assign iqpcm_dump_valid = iqpcm_dump_valid0 | iqpcm_dump_valid_d;
    pcmmux_fifo #(
    .CHANNEL            (2),
    .pcmaw              (1)
    ) pcmmux_fifo_in(
    //clock and reset
    .pcm_in_clk         (pcm_clk),
    .pcm_out_clk        (clk1),
    .rst                (rst | resync),

    //pcm input and output
    .pcm_in_valid       ({da_lb_pcm_in_valid, ad_pcm_in_valid}),
    .pcm_in_ready       ({da_lb_pcm_in_ready, ad_pcm_in_ready}),
    .pcm_in             ({da_lb_pcm_in, ad_pcm_in}),
    .pcm_out_valid      (pcm_in_valid),
    .pcm_out_ready      (1'b1),
    .pcm_out            (pcm_in),

    //register access
    .pcm_channel_choose ({7'b0,choose_lb}),
    .pcm_available      (),
    .pcm_capture_sep    (dec_rate)
    );

    pcmmux_fifo #(
    .CHANNEL            (1),
    .pcmaw              (1)
    ) pcmmux_fifo_iout(
    //clock and reset
    .pcm_in_clk         (clk1),
    .pcm_out_clk        (pcm_clk),
    .rst                (rst | resync),

    //pcm input and output
    .pcm_in_valid       (ipcm_out_valid),
    .pcm_in_ready       (ipcm_out_ready),
    .pcm_in             (ipcm_out),
    .pcm_out_valid      (ipcm_dec_out_valid),
    .pcm_out_ready      (ipcm_dec_out_ready),
    .pcm_out            (ipcm_dec_out),

    //register access
    .pcm_channel_choose (8'd0),
    .pcm_available      (),
    .pcm_capture_sep    (dec_rate2)
    );

    pcmmux_fifo #(
    .CHANNEL            (1),
    .pcmaw              (1)
    ) pcmmux_fifo_qout(
    //clock and reset
    .pcm_in_clk         (clk1),
    .pcm_out_clk        (pcm_clk),
    .rst                (rst | resync),

    //pcm input and output
    .pcm_in_valid       (qpcm_out_valid),
    .pcm_in_ready       (qpcm_out_ready),
    .pcm_in             (qpcm_out),
    .pcm_out_valid      (qpcm_dec_out_valid),
    .pcm_out_ready      (qpcm_dec_out_ready),
    .pcm_out            (qpcm_dec_out),

    //register access
    .pcm_channel_choose (8'd0),
    .pcm_available      (),
    .pcm_capture_sep    (dec_rate2)
    );

    mult #(
    .di1(16),
    .di2(16),
    .dow(32),
    .pipeline(2)
    ) mult_inst(
        .clock              (clk1),
    	.dataa              (pcm_in),
    	.datab              (phase[0] ? qpcm_in : ipcm_in),
    	.result             (mult_result)
    );

    always @(posedge clk1)
    if (rst | resync)
        pcm_in_valid_d <= #1 1'b0;
    else
        pcm_in_valid_d <= #1 pcm_in_valid;

    always @(posedge clk1)
    if (rst | resync)
        phase <= #1 3'd0;
    else
        phase <= #1 {phase[2:0], pcm_in_valid & !pcm_in_valid_d};

    assign iq_next = pcm_in_valid & !pcm_in_valid_d;

    //calculate ipcm and qpcm
    always @(posedge clk1)
    if (phase[1])
        ipcm_out <= #1 mult_result >> pcm_out_shift;

    always @(posedge clk1)
    if (phase[2])
        qpcm_out <= #1 mult_result >> pcm_out_shift;

    always @(posedge clk1)
    if (rst | resync)
        ipcm_out_valid <= #1 1'b0;
    else
        if (phase[1])
            ipcm_out_valid <= #1 1'b1;
        else
            if (ipcm_out_ready)
                ipcm_out_valid <= #1 1'b0;

    always @(posedge clk1)
    if (rst | resync)
        qpcm_out_valid <= #1 1'b0;
    else
        if (phase[2])
            qpcm_out_valid <= #1 1'b1;
        else
            if (qpcm_out_ready)
                qpcm_out_valid <= #1 1'b0;

    //prepare iqpcm_dump
    always @(posedge clk1)
    if (rst | resync)
        iqpcm_dump_valid0 <= #1 1'b0;
    else
        if (ipcm_dec_out_valid)
            iqpcm_dump_valid0 <= #1 1'b1;
        else
            if (iqpcm_dump_valid_d)
                iqpcm_dump_valid0 <= #1 1'b0;

    always @(posedge pcm_clk)
    if (rst | resync)
        iqpcm_dump_valid_d <= #1 1'b0;
    else
        iqpcm_dump_valid_d <= #1 iqpcm_dump_valid0;

    always @(posedge pcm_clk)
    if (rst | resync)
        iqpcm_dump <= #1 0;
    else
    if (iqpcm_dump_valid0)
        iqpcm_dump <= #1 ipcm_dec_out;
    else
        if (iqpcm_dump_valid_d)
            iqpcm_dump <= #1 qpcm_dec_out;

    //calculate acc
    always @(posedge clk1)
        acc_in <= #1 {{16{mult_result[31]}}, mult_result} >> acc_shift;

    always @(posedge clk1)
    if (rst | acc_clr & phase[1] | resync)
        ipcm_acc <= #1 0;
    else
        if (phase[2])
            ipcm_acc <= #1 ipcm_acc + {{8{acc_in[31]}}, acc_in};

    always @(posedge clk1)
    if (rst | acc_clr & phase[1] | resync)
        qpcm_acc <= #1 0;
    else
        if (phase[3])
            qpcm_acc <= #1 qpcm_acc + {{8{acc_in[31]}}, acc_in};

    always @(posedge clk1)
    if (rst | resync)
        ipcm_acc_out <= #1 0;
    else
        if (acc_clr & phase[1])
            ipcm_acc_out <= #1 ipcm_acc[39:8];

    always @(posedge clk1)
    if (rst | resync)
        qpcm_acc_out <= #1 0;
    else
        if (acc_clr & phase[1])
            qpcm_acc_out <= #1 qpcm_acc[39:8];

endmodule