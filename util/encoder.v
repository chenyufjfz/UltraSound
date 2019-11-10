`timescale 1ns / 1ps

module encoder(
    clk,
    rst,
    pulse_width,
    Encoder_A,
    Encoder_B,
    Encoder_dir,
    capture_start,
    Encoder_div_number,
    o_encoder_cnt_div_a,
    encoder_total_a,
    encoder_total_b,
    o_encoder_err,
    err_status
);

    input                   clk;
    input                   rst;
    input [11:0]            pulse_width;
    input                   Encoder_A;
    input                   Encoder_B;
    input                   Encoder_dir;
    input                   capture_start;
    input                   Encoder_div_number;
    output [31:0]           o_encoder_cnt_div_a;
    output reg [31:0]       encoder_total_a;
    output reg [31:0]       encoder_total_b;
    output                  o_encoder_err;
    output reg [2:0]        err_status;

    //internal reg
    reg [1:0]               state_A, state_B;
    reg [1:0]               pp_enc_A, pp_enc_B;
    reg [32:0]              encoder_cnt;
    reg [1:0]               encoder_diff;
    reg [11:0]              pulse_cycle_a;
    reg [11:0]              pulse_cycle_b;
    reg [1:0]               ab_diff;
    reg [2:0]               encoder_err;

    always @(posedge clk)
    if (rst || !capture_start)
        state_A <= #1 1;
    else
        case (state_A)
        0: state_A <= #1 Encoder_A;
        1: state_A <= #1 Encoder_A ? 3 : 0;
        2: state_A <= #1 Encoder_A ? 3 : 0;
        3: state_A <= #1 Encoder_A ? 3 : 2;
        endcase

    always @(posedge clk)
        pp_enc_A <= #1 {pp_enc_A[0], (state_A >= 2)};
                
    always @(posedge clk)
    if (rst || !capture_start)
        state_B <= #1 1;
    else
        case (state_B)
        0: state_B <= #1 Encoder_B;
        1: state_B <= #1 Encoder_B ? 3 : 0;
        2: state_B <= #1 Encoder_B ? 3 : 0;
        3: state_B <= #1 Encoder_B ? 3 : 2;
        endcase
        
    always @(posedge clk)
        pp_enc_B <= #1 {pp_enc_B[0], (state_B >= 2)};     

    always @(posedge clk)
    if (rst || !capture_start)
        encoder_cnt <= #1 0;
    else
        if (pp_enc_A[0] & !pp_enc_A[1])
            if (Encoder_dir ^ pp_enc_B[0])
                encoder_cnt <= #1 encoder_cnt + 1'b1;
            else
                encoder_cnt <= #1 encoder_cnt - 1'b1;

    always @(posedge clk)
    if (rst || !capture_start)
        encoder_total_a <= #1 0;
    else
        if (pp_enc_A[0] & !pp_enc_A[1])
            encoder_total_a <= #1 encoder_total_a + 1;

    always @(posedge clk)
    if (rst || !capture_start)
        encoder_total_b <= #1 0;
    else
        if (pp_enc_B[0] & !pp_enc_B[1])
            encoder_total_b <= #1 encoder_total_b + 1;

    assign o_encoder_cnt_div_a = Encoder_div_number ? encoder_cnt[32:1] : encoder_cnt[31:0];

    always @(posedge clk)
    if (rst || !capture_start)
        pulse_cycle_a <= #1 3999;
    else
        if (pp_enc_A[0] & !pp_enc_A[1])
            pulse_cycle_a <= #1 0;
        else
            pulse_cycle_a <= #1 pulse_cycle_a + 1;

    always @(posedge clk)
    if (rst || !capture_start)
        encoder_err[0] <= #1 0;
    else
        if (pp_enc_A[0] & !pp_enc_A[1])
            encoder_err[0] <= #1 (pulse_cycle_a < pulse_width);


    always @(posedge clk)
    if (rst || !capture_start)
        pulse_cycle_b <= #1 3999;
    else
        if (pp_enc_B[0] & !pp_enc_B[1])
            pulse_cycle_b <= #1 0;
        else
            pulse_cycle_b <= #1 pulse_cycle_b + 1;

    always @(posedge clk)
    if (rst || !capture_start)
        encoder_err[1] <= #1 0;
    else
        if (pp_enc_B[0] & !pp_enc_B[1])
            encoder_err[1] <= #1 (pulse_cycle_b < pulse_width);

    always @(posedge clk)
    if (rst || !capture_start || encoder_err[2])
        ab_diff <= #1 2;
    else
        if (pp_enc_A[0] & !pp_enc_A[1] && !(pp_enc_B[0] & !pp_enc_B[1]))
            ab_diff <= #1 ab_diff + 1;
        else
            if (pp_enc_B[0] & !pp_enc_B[1] && !(pp_enc_A[0] & !pp_enc_A[1]))
                ab_diff <= #1 ab_diff - 1;

    always @(posedge clk)
    if (ab_diff == 0)
        encoder_err[2] <= #1 1;
    else
        encoder_err[2] <= #1 0;
        
    always @(posedge clk)
    if (rst || !capture_start)
        err_status <= #1 0;
    else
    begin
        if (encoder_err[0])
            err_status[0] <= #1 1;
        if (encoder_err[1])
            err_status[1] <= #1 1;
        if (encoder_err[2])
            err_status[2] <= #1 1;
    end
        
    assign o_encoder_err = encoder_err[0] | encoder_err[1] | encoder_err[2];
endmodule