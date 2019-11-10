`timescale 1ns / 1ps

module sincos_mem(
    //clock and reset
    da_clk,
    rst,

    //pcm input and output
    pcm_out_valid,
    pcm_out_ready,
    ipcm_out,
    qpcm_out,

    //register access
    clk_2,
    reg_addr,
    reg_rd,
    reg_wr,
    reg_ready,
    reg_writedata,
    reg_readdata,

    sin_length,
    resync,
    status
);
parameter pcmaw=10;
parameter UNIT1=16'h4000;

    //clock and reset
    input                       da_clk;
    input                       rst;

    //pcm input and output
    output reg                  pcm_out_valid;
    input                       pcm_out_ready;
    output reg [15:0]           ipcm_out;
    output reg [15:0]           qpcm_out;

    //register access
    input                       clk_2;
    input [pcmaw-1:0]           reg_addr;
    input                       reg_rd;
    input                       reg_wr;
    output reg                  reg_ready;
    input [31:0]                reg_writedata;
    output [31:0]               reg_readdata;

    //controller
    input [pcmaw:0]             sin_length;
    input                       resync;
    output [15:0]               status;

    //internal wire & reg
    wire [15:0]                 qpcm, ipcm;
    reg [pcmaw-1:0]             sin_addr;
    reg                         sin_phase;

    generic_dpram #(
        .adw                (32),
        .aaw                (pcmaw),
        .bdw                (32),
        .pipeline           (1)
    ) sin_mem (
        .address_a          (sin_addr),
        .address_b          (reg_addr),
        .clock_a            (da_clk),
        .clock_b            (clk_2),
        .data_a             (),
        .data_b             (reg_writedata),
        .rden_a             (pcm_out_ready & pcm_out_valid || !pcm_out_valid),
        .rden_b             (1'b1),
        .wren_a             (1'b0),
        .wren_b             (reg_wr),
        .q_a                ({ipcm, qpcm}),
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

    always @(posedge da_clk)
    if (rst || resync)
    begin
        sin_addr <= #1 1;
        sin_phase <= #1 1'b0;
    end
    else
    if (pcm_out_ready & pcm_out_valid  || !pcm_out_valid)
    begin
        if (sin_addr == sin_length[pcmaw:1] && sin_phase == 1'b0)
        begin
            sin_addr <= sin_length[0] ? sin_addr : sin_addr - 1;
            sin_phase <= #1 1'b1;
        end
        else
            if (sin_addr == 0)
            begin
                sin_phase <= #1 1'b0;
                sin_addr <= #1 1;
            end
            else
                sin_addr <= #1 sin_phase ? sin_addr - 1 : sin_addr + 1;
    end

    always @(posedge da_clk)
    if (rst || resync)
        pcm_out_valid <= #1 1'b0;
    else
        pcm_out_valid <= #1 1'b1;

    always @(posedge da_clk)
    if (rst || resync || sin_length==0)
    begin
        ipcm_out <= #1 (sin_length==0) ? 0 : UNIT1;
        qpcm_out <= #1 16'd0;
    end
    else
    if (pcm_out_ready & pcm_out_valid)
    begin
        ipcm_out <= #1 ipcm;
        qpcm_out <= #1 sin_phase ? -qpcm : qpcm;
    end
    
    assign status = {sin_phase, sin_addr};
endmodule