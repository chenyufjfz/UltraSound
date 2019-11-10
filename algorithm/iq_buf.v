`timescale 1ns / 1ps

module iq_buf(
    clk,
    rst,

    //iq pcm input
    mf_ipcm_acc_out,
    mf_qpcm_acc_out,
    sync_slot,
    sync_encoder1,
    sync_encoder2,

    //controller
    mf_iq_read,
    iq_buf_write,
    iq_buf_read,
    iq_buf_rst,
    iq_buf_block_ov,
    iq_buf_overflow,

    //AXI access
    reg_addr,
    reg_readdata,
    reg_wr,
    reg_rd,
    reg_ready
);
parameter ADC_CHANNEL = 8;
parameter FREQ_NUM = 5;
parameter BUF_NUM=80;
localparam REG_NUM = ADC_CHANNEL*FREQ_NUM*2 + 3;
localparam sw=$clog2(REG_NUM);


    input                                   clk;
    input                                   rst;

    //iq pcm input
    input [32*ADC_CHANNEL*FREQ_NUM-1:0]     mf_ipcm_acc_out;
    input [32*ADC_CHANNEL*FREQ_NUM-1:0]     mf_qpcm_acc_out;
    input [31:0]                            sync_slot;
    input [31:0]                            sync_encoder1;
    input [31:0]                            sync_encoder2;

    //controller
    input                                   mf_iq_read;
    output reg [15:0]                       iq_buf_write;
    input [15:0]                            iq_buf_read;
    input                                   iq_buf_rst;
    input                                   iq_buf_block_ov;
    output reg                              iq_buf_overflow;

    //AXI access
    input [15:0]                            reg_addr;
    output [31:0]                           reg_readdata;
    input                                   reg_wr;
    input                                   reg_rd;
    output                                  reg_ready;

    //internal wire
    wire [sw-1:0]                           select;
    wire                                    write_busy;
    reg                                     rst_during_write;

    reg2ram #(
    .REG_NUM            (REG_NUM),
    .BUF_NUM            (BUF_NUM)
    ) reg2ram_inst(
    .clk                (clk),
    .rst                (rst),
    .seq_reg            ({mf_qpcm_acc_out, mf_ipcm_acc_out, sync_encoder2, sync_encoder1, sync_slot}),

    //controller interface
    .write_addr         (iq_buf_write),
    .write_trigger      (mf_iq_read),
    .write_rst          (iq_buf_rst),
    .select             (select),
    .write_busy         (write_busy),

    //AXI interface
    .reg_readdata       (reg_readdata),
    .reg_wr             (reg_wr),
    .reg_rd             (reg_rd),
    .reg_ready          (reg_ready),
    .reg_addr           (reg_addr)
    );

    always @(posedge clk)
    if (rst || iq_buf_rst || rst_during_write)
        iq_buf_write <= #1 0;
    else
        if (select >= REG_NUM -1)
            if (iq_buf_block_ov && iq_buf_write == iq_buf_read)
                iq_buf_write <= #1 iq_buf_write;
            else
                iq_buf_write <= #1 (iq_buf_write >=  REG_NUM * (BUF_NUM -1)) ? 0 : iq_buf_write+REG_NUM;

    always @(posedge clk)
    if (rst)
        rst_during_write <= #1 0;
    else
        if (!write_busy)
            rst_during_write <= #1 0;
        else
            if (iq_buf_rst)
                rst_during_write <= #1 1;
                
    always @(posedge clk)
    if (rst || iq_buf_rst)
        iq_buf_overflow <= #1 0;
    else
        if (select >= REG_NUM -1 && iq_buf_write == iq_buf_read)
            iq_buf_overflow <= #1 1;
endmodule

