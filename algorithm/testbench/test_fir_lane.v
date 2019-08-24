`timescale 1ns / 1ps
module test_fir_lane;
parameter acw = 30; //affect accuracy
parameter pcmaw = 8;
parameter mul_num = 2;
localparam paw = (mul_num==2) ? pcmaw-1 : ((mul_num==1) ? pcmaw : 0);
localparam pqw = (mul_num==2) ? 32 : 16;

    //reset and clock
    reg             rst;
    reg             clk1;
    reg             pcm_clk;

    //pcm inout which is pcm_clk domain
    reg             pcm_in_wr;
    reg [15:0]      pcm_in;
    reg [pcmaw-1:0] pcm_in_address;
    wire [15:0]     pcm_out;

    //param input which is clk1 domain
    wire [pqw-1:0]  param_q;
    wire [paw-1:0]  param_addr;

    //control which is pcm_clk domain
    reg [3:0]       pcm_out_shift;
    reg             fir_start;
    reg [11:0]      tap_len;
    reg [15:0]      result[1023: 0];
    integer         result_idx;
    
fir_lane #(
    .acw            (acw),
    .pcmaw          (pcmaw),
    .mul_num        (mul_num)
) fir_lane_inst(
    //reset and clock
    .rst            (rst),
    .clk1           (clk1),
    .pcm_clk        (pcm_clk),

    //pcm inout which is pcm_clk domain
    .pcm_in_wr      (pcm_in_wr),
    .pcm_in         (pcm_in),
    .pcm_in_address (pcm_in_address),
    .pcm_out        (pcm_out),

    //param input which is clk1 domain
    .param_q        (param_q),
    .param_addr     (param_addr),

    //control which is pcm_clk domain
    .pcm_out_shift  (pcm_out_shift),
    .fir_start      (fir_start),
    .tap_len        (tap_len)
);

generic_spram #(
    .aw             (paw),
    .dw             (pqw)
) 
param_ram 
(
    .clk            (clk1),
    .re             (1'b1),
    .we             (1'b0),
    .addr           (param_addr),
    .q              (param_q),
    .data           ()
);

always
begin
    pcm_clk <= 1'b 1;
    #5;
    pcm_clk <= 1'b 0;
    #5;
end

always
begin
    clk1 <= 1'b 1;
    #3;
    clk1 <= 1'b 0;
    #2;
end

task automatic generate_pcm_in;
    input integer num;
    input integer sep;
    input integer downsample;
    input integer record_result;
    integer i, j, k;
    
    begin
        pcm_in_wr <= #1 0;
        fir_start <= #1 0;
        k = 0;
        for (i=0; i<num; i=i+1)
        begin
            for (j=0; j+1<sep; j=j+1)
                @(posedge pcm_clk);
            k = k + 1;
            if (k == downsample)
            begin
                k = 0;
                fir_start <= #1 1;
            end
            pcm_in_wr <= #1 1;
            @(posedge pcm_clk);
            pcm_in_wr <= #1 0;
            fir_start <= #1 0;
            pcm_in <= #1 (pcm_in + 1 < tap_len * mul_num) ? pcm_in + 1 : 0;
            pcm_in_address <= #1 pcm_in_address + 1;
            if (k==0 && record_result)
            begin
                result[result_idx] <= #1 pcm_out;
                result_idx = result_idx + 1;
            end
        end
    end
endtask

initial
begin
    rst = 0;
    if (mul_num==2)
        $readmemh("../testbench/param.txt",param_ram.SIM_RAM.mem);
    else
        $readmemh("../testbench/param1.txt",param_ram.SIM_RAM.mem);
    @(posedge clk1);
    rst = 1;
    pcm_in_address = 0;
    pcm_in_wr = 0;
    pcm_out_shift = 13;
    fir_start = 0;
    tap_len = 8;
    result_idx = 0;
    #100;
    @(posedge clk1);
    rst = 0;
    pcm_in = 0;
    generate_pcm_in(18, 7, 1, 0);
    generate_pcm_in(20, 7, 1, 1);
    tap_len = 9;
    @(posedge clk1);
    pcm_in = 0;
    generate_pcm_in(19, 7, 1, 0);
    generate_pcm_in(20, 7, 1, 1);
    tap_len = 10;
    @(posedge clk1);
    pcm_in = 0;
    generate_pcm_in(22, 7, 1, 0);
    generate_pcm_in(20, 7, 1, 1);
    tap_len = 11;
    @(posedge clk1);
    pcm_in = 0;
    generate_pcm_in(30, 7, 1, 0);
    generate_pcm_in(20, 7, 1, 1);
    tap_len = 12;
    @(posedge clk1);
    pcm_in = 0;
    generate_pcm_in(25, 5, 2, 0);
    generate_pcm_in(20, 5, 2, 1);
    tap_len = 16;
    @(posedge clk1);
    pcm_in = 0;
    generate_pcm_in(50, 5, 2, 0);
    generate_pcm_in(20, 5, 2, 1);
    tap_len = 17;
    @(posedge clk1);
    pcm_in = 0;
    generate_pcm_in(50, 5, 2, 0);
    generate_pcm_in(20, 5, 2, 1);
    tap_len = 18;
    @(posedge clk1);
    pcm_in = 0;
    generate_pcm_in(50, 5, 2, 0);
    generate_pcm_in(20, 5, 2, 1);
    tap_len = 19;
    @(posedge clk1);
    pcm_in = 0;
    generate_pcm_in(50, 5, 2, 0);
    generate_pcm_in(20, 5, 2, 1);
    $writememh("../testbench/fir_lane_out.txt",result);
    $stop;
end    
endmodule