`timescale 1ns / 1ps

module shadow_sc(
    clk,
    rst,

    //controller interface
    shadow_cos_sita,
    shadow_sin_sita,
    shadow_choose,
    shadow_read_addr,
    shadow_read_trigger,

    //AXI interface
    reg_readdata,
    reg_writedata,
    reg_rd,
    reg_wr,
    reg_ready,
    reg_addr
);
parameter MIX_NUM = 5;
parameter DAC_CHANNEL = 10;

    input                                   clk;
    input                                   rst;

    //shadow dac sin cos
    output [16*MIX_NUM*DAC_CHANNEL-1:0]     shadow_cos_sita;
    output [16*MIX_NUM*DAC_CHANNEL-1:0]     shadow_sin_sita;
    output [4*MIX_NUM*DAC_CHANNEL-1:0]      shadow_choose;
    input [15:0]                            shadow_read_addr;
    input                                   shadow_read_trigger;

    //AXI access
    input [15:0]                            reg_addr;
    output [31:0]                           reg_readdata;
    input [31:0]                            reg_writedata;
    input                                   reg_rd;
    input                                   reg_wr;
    output                                  reg_ready;
    
    wire [255:0]                            shadow_choose_256;
    assign shadow_choose = shadow_choose_256;

ram2reg #(
    .REG_NUM                                (MIX_NUM*DAC_CHANNEL + 8),
    .BUF_NUM                                (16)
) ram2reg_inst(
    .clk                                    (clk),
    .rst                                    (rst),
    .seq_reg                                ({shadow_sin_sita, shadow_cos_sita, shadow_choose_256}),

    //controller interface
    .read_addr                              (shadow_read_addr),
    .read_trigger                           (shadow_read_trigger),

    //AXI interface
    .reg_readdata                           (reg_readdata),
    .reg_writedata                          (reg_writedata),
    .reg_rd                                 (reg_rd),
    .reg_wr                                 (reg_wr),
    .reg_ready                              (reg_ready),
    .reg_addr                               (reg_addr)
);
endmodule