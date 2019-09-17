`timescale 1ns / 1ps

module mix_freq_mc(
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
    clk_2,
    reg_addr,
    reg_rd,
    reg_wr,
    reg_ready,
    reg_writedata,
    reg_readdata,

    //controller input
    pcm_out_shift,
    choose_lb,
    dec_rate,
    dec_rate2,
    acc_shift,
    sin_length,
    cycle_num,
    status,
    resync
);
parameter CHANNEL = 8;
parameter pcmaw = 12;

    //reset and clock
    input                   rst;
    input                   clk1;
    input                   pcm_clk;

    //pcm input
    input [CHANNEL-1:0]     ad_pcm_in_valid;
    output [CHANNEL-1:0]    ad_pcm_in_ready;
    input [16*CHANNEL-1:0]  ad_pcm_in;
    input [CHANNEL-1:0]     da_lb_pcm_in_valid;
    output [CHANNEL-1:0]    da_lb_pcm_in_ready;
    input [16*CHANNEL-1:0]  da_lb_pcm_in;

    //iq pcm output
    output [CHANNEL-1:0]    ipcm_dec_out_valid;
    input [CHANNEL-1:0]     ipcm_dec_out_ready;
    output [16*CHANNEL-1:0] ipcm_dec_out;
    output [32*CHANNEL-1:0] ipcm_acc_out;
    output [CHANNEL-1:0]    qpcm_dec_out_valid;
    input [CHANNEL-1:0]     qpcm_dec_out_ready;
    output [16*CHANNEL-1:0] qpcm_dec_out;
    output [32*CHANNEL-1:0] qpcm_acc_out;
    output [CHANNEL-1:0]    iqpcm_dump_valid;
    output [16*CHANNEL-1:0] iqpcm_dump;

    //register access
    input                   clk_2;
    input [12:0]            reg_addr;
    input                   reg_rd;
    input                   reg_wr;
    output reg              reg_ready;
    input [31:0]            reg_writedata;
    output [31:0]           reg_readdata;

    //controller input
    input [3:0]             pcm_out_shift;
    input                   choose_lb;
    input [7:0]             dec_rate;
    input [7:0]             dec_rate2;
    input [3:0]             acc_shift;
    input [pcmaw-1:0]       sin_length;
    input [23:0]            cycle_num;
    output [31:0]           status;
    input                   resync;

    //internal wire & reg    
    reg [15:0]              ipcm_in;
    reg [15:0]              qpcm_in;
    wire                    iq_next;
    reg [2:0]               iq_next_d;
    reg [pcmaw-2:0]         sin_addr;
    wire [pcmaw-1:0]        pcm_addr;
    wire [15:0]             pcm_q;
    reg [15:0]              pcm_q_d;
    reg                     sin_phase;
    reg [23:0]              cycle;
    wire [14:0]             sin_addr_15;

    mix_freq mix_freq_inst0(
        //reset and clock
        .rst                (rst),
        .clk1               (clk1),
        .pcm_clk            (pcm_clk),

        //pcm input
        .ad_pcm_in_valid    (ad_pcm_in_valid[0]),
        .ad_pcm_in_ready    (ad_pcm_in_ready[0]),
        .ad_pcm_in          (ad_pcm_in[15:0]),
        .da_lb_pcm_in_valid (da_lb_pcm_in_valid[0]),
        .da_lb_pcm_in_ready (da_lb_pcm_in_ready[0]),
        .da_lb_pcm_in       (da_lb_pcm_in[15:0]),

        //iq pcm input
        .ipcm_in            (ipcm_in),
        .qpcm_in            (qpcm_in),
        .iq_next            (iq_next),

        //iq pcm output
        .ipcm_dec_out_valid (ipcm_dec_out_valid[0]),
        .ipcm_dec_out_ready (ipcm_dec_out_ready[0]),
        .ipcm_dec_out       (ipcm_dec_out[15:0]),
        .ipcm_acc_out       (ipcm_acc_out[31:0]),
        .qpcm_dec_out_valid (qpcm_dec_out_valid[0]),
        .qpcm_dec_out_ready (qpcm_dec_out_ready[0]),
        .qpcm_dec_out       (qpcm_dec_out[15:0]),
        .qpcm_acc_out       (qpcm_acc_out[31:0]),
        .iqpcm_dump_valid   (iqpcm_dump_valid[0]),
        .iqpcm_dump         (iqpcm_dump[15:0]),

        //register access
        .pcm_out_shift      (pcm_out_shift),
        .choose_lb          (choose_lb),
        .dec_rate           (dec_rate),
        .dec_rate2          (dec_rate2),
        .acc_clr            (sin_addr == 1 && sin_phase==0 && cycle == cycle_num),
        .acc_shift          (acc_shift),
        .resync             (resync)
    );
generate
    genvar k;
    for (k=1; k<CHANNEL; k=k+1)
    begin : mix_freq_create
    mix_freq mix_freq_inst(
        //reset and clock
        .rst                (rst),
        .clk1               (clk1),
        .pcm_clk            (pcm_clk),

        //pcm input
        .ad_pcm_in_valid    (ad_pcm_in_valid[k]),
        .ad_pcm_in_ready    (ad_pcm_in_ready[k]),
        .ad_pcm_in          (ad_pcm_in[16*k+15:16*k]),
        .da_lb_pcm_in_valid (da_lb_pcm_in_valid[k]),
        .da_lb_pcm_in_ready (da_lb_pcm_in_ready[k]),
        .da_lb_pcm_in       (da_lb_pcm_in[16*k+15:16*k]),

        //iq pcm input
        .ipcm_in            (ipcm_in),
        .qpcm_in            (qpcm_in),
        .iq_next            (),

        //iq pcm output
        .ipcm_dec_out_valid (ipcm_dec_out_valid[k]),
        .ipcm_dec_out_ready (ipcm_dec_out_ready[k]),
        .ipcm_dec_out       (ipcm_dec_out[16*k+15:16*k]),
        .ipcm_acc_out       (ipcm_acc_out[32*k+31:32*k]),
        .qpcm_dec_out_valid (qpcm_dec_out_valid[k]),
        .qpcm_dec_out_ready (qpcm_dec_out_ready[k]),
        .qpcm_dec_out       (qpcm_dec_out[16*k+15:16*k]),
        .qpcm_acc_out       (qpcm_acc_out[32*k+31:32*k]),
        .iqpcm_dump_valid   (iqpcm_dump_valid[k]),
        .iqpcm_dump         (iqpcm_dump[16*k+15:16*k]),

        //register access
        .pcm_out_shift      (pcm_out_shift),
        .choose_lb          (choose_lb),
        .dec_rate           (dec_rate),
        .dec_rate2          (dec_rate2),
        .acc_clr            (sin_addr == 1 && sin_phase==0 && cycle == cycle_num),
        .acc_shift          (acc_shift),
        .resync             (resync)
    );
    end
endgenerate
    
    generic_dpram #(
        .adw                (16),
        .aaw                (pcmaw),
        .bdw                (32),
        .pipeline           (1)
    ) sin_mem (
        .address_a          (pcm_addr),
        .address_b          (reg_addr[pcmaw-2:0]),
        .clock_a            (clk1),
        .clock_b            (clk_2),
        .data_a             (),
        .data_b             (reg_writedata),
        .rden_a             (1'b1),
        .rden_b             (1'b1),
        .wren_a             (1'b0),
        .wren_b             (reg_wr),
        .q_a                (pcm_q),
        .q_b                (reg_readdata)
    );

    always @(posedge clk_2 or posedge rst)
    if (rst)
        reg_ready <= #1 0;
    else
        if (reg_wr | reg_rd)
            reg_ready <= #1 !reg_ready;
        else
            reg_ready <= #1 0;

    always @(posedge clk1)
    if (rst || resync)
        iq_next_d <= #1 3'd1;
    else
        iq_next_d <= {iq_next_d[1:0], iq_next};

    always @(posedge clk1)
    if (rst || resync)
    begin
        sin_addr <= #1 2;
        sin_phase <= #1 1'b1;
        cycle <= #1 0;
    end
    else
    if (iq_next_d[2])
    begin
        if (sin_addr == sin_length[pcmaw-1:1] && sin_phase == 1'b0)
        begin
            sin_addr <= sin_length[0] ? sin_addr : sin_addr - 1;
            sin_phase <= #1 1'b1;
        end
        else
            if (sin_addr == 0)
            begin
                sin_phase <= #1 1'b0;
                sin_addr <= #1 1;
                cycle <= #1 (cycle == cycle_num) ? 0 : cycle + 1'b1;
            end
            else
                sin_addr <= #1 sin_phase ? sin_addr - 1 : sin_addr + 1;
    end

    assign pcm_addr = iq_next_d[0] ? { sin_addr, 1'b0} : {sin_addr, 1'b1};
    assign sin_addr_15 = sin_addr;
    assign status = {cycle[15:0], sin_phase, sin_addr_15};
    
    always @(posedge clk1)
    if (iq_next_d[1])
        ipcm_in <= #1 pcm_q_d;

    always @(posedge clk1)
    if (iq_next_d[2])
        qpcm_in <= #1 sin_phase ? -pcm_q_d : pcm_q_d;
        
    always @(posedge clk1)
        pcm_q_d <= #1 pcm_q;
endmodule

