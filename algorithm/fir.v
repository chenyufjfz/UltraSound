`timescale 1ns / 1ps

module fir
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

    //fir parameter input
    param_q,
    param_addr,

    //control
    pcm_out_shift,
    bypass,
    down_sample,
    tap_len
);
parameter FIR_LANE = 4; //compute clock = down_sampe * FIR_LANE * (clk1 / sample)
parameter gen_param_addr = 1;
parameter acw = 31;
parameter pcmaw = 9;
parameter mul_num = 2;
localparam paw = (mul_num==2) ? pcmaw-1 : ((mul_num==1) ? pcmaw : 0);
localparam pqw = (mul_num==2) ? 32 : 16;

    //clock and reset
    input                           pcm_clk;
    input                           clk1;
    input                           rst;

    //pcm input and output
    input                           pcm_in_valid;
    output                          pcm_in_ready;
    input [15:0]                    pcm_in;
    output reg                      pcm_out_valid;
    input                           pcm_out_ready;
    output reg [15:0]               pcm_out;

    //fir parameter input
    input [FIR_LANE * pqw - 1:0]    param_q;
    output [FIR_LANE * paw - 1:0]   param_addr;

    //control
    input [3:0]                     pcm_out_shift;
    input                           bypass;
    input [11:0]                    down_sample;
    input [11:0]                    tap_len;

    //internal reg
    reg [pcmaw-1:0]                 pcm_in_address;
    wire [15:0]                     pcm_out_lane[FIR_LANE-1 : 0];
    wire [FIR_LANE-1 : 0]           fir_start;
    reg [11:0]                      sample_num;
    reg [4:0]                       lane_idx;
    wire [4:0]                      lane_idx_next;
    
    assign pcm_in_ready = 1;
    
    generate
    genvar k;
        for (k=0; k<FIR_LANE; k=k+1)
        begin : fir_lane_create
            fir_lane #(
            .gen_param_addr (gen_param_addr),
            .acw            (acw),
            .pcmaw          (pcmaw),
            .mul_num        (mul_num)
            )
            fir_lane_inst(
            //reset and clock
            .rst            (rst),
            .clk1           (clk1),
            .pcm_clk        (pcm_clk),
        
            //pcm inout which is pcm_clk domain
            .pcm_in_wr      (pcm_in_valid),
            .pcm_in         (pcm_in),
            .pcm_in_address (pcm_in_address),
            .pcm_out        (pcm_out_lane[k]),
        
            //param input which is clk1 domain
            .param_q        (param_q[pqw*k+pqw-1:pqw*k]),
            .param_addr     (param_addr[paw*k+paw-1:paw*k]),
        
            //control which is pcm_clk domain
            .pcm_out_shift  (pcm_out_shift),
            .fir_start      (fir_start[k]),
            .tap_len        (tap_len)
        );
        assign fir_start[k] = (lane_idx == k) && pcm_in_valid && (sample_num == down_sample);
        end
    endgenerate
    
    always @(posedge pcm_clk)
    if (rst)
        pcm_in_address <= #1 0;
    else
        if (pcm_in_valid)
            pcm_in_address <= #1 pcm_in_address + 1;
            
    always @(posedge pcm_clk)
    if (rst)
        sample_num <= #1 1;
    else
        if (pcm_in_valid)
            sample_num <= #1 (sample_num == down_sample) ? 1 : sample_num + 1;
    
    assign lane_idx_next = (lane_idx == FIR_LANE -1) ? 0 : lane_idx + 1;
    
    always @(posedge pcm_clk)
    if (rst)
        lane_idx <= #1 0;
    else
        if (pcm_in_valid && sample_num == down_sample)
            lane_idx <= #1 lane_idx_next;
    
    always @(posedge pcm_clk)
    if (pcm_in_valid && sample_num == down_sample)
        pcm_out <= #1 bypass ? pcm_in : pcm_out_lane[lane_idx_next];
        
    always @(posedge pcm_clk)
    if (rst)
        pcm_out_valid <= #1 0;
    else
        if (pcm_in_valid && sample_num == down_sample)
            pcm_out_valid <= #1 1'b1;
        else
            if (pcm_out_ready)
                pcm_out_valid <= #1 1'b0;
endmodule