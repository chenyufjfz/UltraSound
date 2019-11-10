`timescale 1ns / 1ps

module mix_freq2 (
    //reset and clock
    rst,
    clk1,
    ad_clk,

    //pcm input
    ad_pcm_in_valid,
    ad_pcm_in,
    da_lb_pcm_in_valid,
    da_lb_pcm_in,

    //iq pcm input
    ipcm_in,
    qpcm_in,
    iqpcm_valid,
    ad_valid,
    ipcm_acc_out,
    qpcm_acc_out,

    //register access
    choose_lb,
    acc_shift,
    cycle_num,
    err_clr,
    err
);

    //reset and clock
    input               rst;
    input               clk1;
    input               ad_clk;

    //pcm input
    input               ad_pcm_in_valid;
    input [15:0]        ad_pcm_in;
    input               da_lb_pcm_in_valid;
    input [15:0]        da_lb_pcm_in;

    //iq pcm input
    input [15:0]        ipcm_in;
    input [15:0]        qpcm_in;
    input               iqpcm_valid;
    input               ad_valid;
    output reg [31:0]   ipcm_acc_out;
    output reg [31:0]   qpcm_acc_out;

    //register access
    input               choose_lb;
    input [3:0]         acc_shift;
    input [23:0]        cycle_num;
    input               err_clr;
    output reg [1:0]    err;

    //internal reg
    reg [23:0]          cycle;
    reg [15:0]          ipcm_in_d, qpcm_in_d, qpcm_in_dd;
    reg [39:0]          ipcm_acc, qpcm_acc;
    reg [31:0]          acc_in;
    reg [3:0]           phase, acc_clr;
    reg                 ad_valid_d;
    wire                ad_clk1_en;
    reg                 new_cycle;
    wire [15:0]         pcm_in;
    reg [15:0]          pcm_in_d;
    wire                pcm_in_valid;
    wire [31:0]         mult_result;
    reg [15:0]          ad_pcm_in_d;
               
    assign pcm_in_valid = ad_clk1_en;
    assign pcm_in = choose_lb ? da_lb_pcm_in : ad_pcm_in;
    
     mult #(
    .di1(16),
    .di2(16),
    .dow(32),
    .pipeline(2)
    ) mult_inst(
        .clock              (clk1),
        .dataa              (pcm_in_d),
        .datab              (pcm_in_valid ? ipcm_in_d : qpcm_in_dd),
        .result             (mult_result)
    );

    always @(posedge clk1)
        ad_valid_d <= #1 ad_valid;
        
    always @(posedge ad_clk)
        pcm_in_d <= #1 pcm_in;
        
    assign ad_clk1_en = !ad_valid_d & ad_valid;

    always @(posedge clk1)
    if (ad_clk1_en)
    begin
        ipcm_in_d <= #1 ipcm_in;
        qpcm_in_d <= #1 qpcm_in;
    end

    always @(posedge clk1)
    if (rst)
    begin
        new_cycle <= #1 1'b0;
        cycle <= #1 0;
    end
    else
        if (ad_clk1_en)
        begin
            new_cycle <= #1 qpcm_in_d[15] & !qpcm_in[15];
            if (qpcm_in_d[15] & !qpcm_in[15])
                cycle <= #1 (cycle >= cycle_num) ? 0 : cycle + 1'b1;
        end

    always @(posedge clk1)
    if (pcm_in_valid)
        qpcm_in_dd <= #1 qpcm_in_d;

    always @(posedge clk1)
    if (rst)
        phase <= #1 0;
    else
        phase <= #1 {phase[2:0], pcm_in_valid};

    always @(posedge clk1)
    if (rst)
        acc_clr <= #1 0;
    else
        acc_clr <= #1 {acc_clr[2:0], pcm_in_valid & (cycle == 0 && new_cycle ? 1'b1 : 1'b0)};

    //calculate acc
    always @(posedge clk1)
        acc_in <= #1 {{16{mult_result[31]}}, mult_result} >> acc_shift;

    always @(posedge clk1)
    if (rst)
        ipcm_acc <= #1 0;
    else
        if (phase[2])
            ipcm_acc <= #1 acc_clr[2] ? {{8{acc_in[31]}}, acc_in} : ipcm_acc + {{8{acc_in[31]}}, acc_in};

    always @(posedge clk1)
    if (rst)
        qpcm_acc <= #1 0;
    else
        if (phase[3])
            qpcm_acc <= #1 acc_clr[3] ? {{8{acc_in[31]}}, acc_in} : qpcm_acc + {{8{acc_in[31]}}, acc_in};

    always @(posedge clk1)
    if (acc_clr[2])
        ipcm_acc_out <= #1 ipcm_acc[39:8];

    always @(posedge clk1)
    if (acc_clr[3])
        qpcm_acc_out <= #1 qpcm_acc[39:8];
        
    always @(posedge clk1)
    if (err_clr | rst)
        err[0] <= #1 1'b0;
    else
        if (ipcm_acc[39] ^ ipcm_acc[38])
            err[0] <= #1 1'b1;
            
    always @(posedge clk1)
    if (err_clr | rst)
        err[1] <= #1 1'b0;
    else
        if (qpcm_acc[39] ^ qpcm_acc[38])
            err[1] <= #1 1'b1;
endmodule