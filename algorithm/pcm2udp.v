`timescale 1ns / 1ps
module pcm2udp (
    //clock and reset
    pcm_in_clk,
    clk,
    rst,

    //pcm input and output
    pcm_in_valid,
    pcm_in,

    //UDP frame output
    pcm_udp_hdr_valid,
    pcm_udp_hdr_ready,
    pcm_udp_length,
    pcm_udp_payload_axis_tdata,
    pcm_udp_payload_axis_tvalid,
    pcm_udp_payload_axis_tready,
    pcm_udp_payload_axis_tlast,

    //regiser access
    pcm_udp_tx_left,
    pcm_udp_tx_start,
    pcm_udp_tx_total,
    pcm_udp_tx_th,
    pcm_udp_channel_choose,
    pcm_udp_capture_sep
);
    parameter CHANNEL=3;
    parameter pcmaw=10;
    parameter PCM_UDP_PACKET_TYPE = 8'he0;
    input                   pcm_in_clk;
    input                   clk;
    input                   rst;
    input [CHANNEL-1:0]     pcm_in_valid;
    input [16*CHANNEL-1:0]  pcm_in;
    output reg              pcm_udp_hdr_valid;
    input                   pcm_udp_hdr_ready;
    output [15:0]           pcm_udp_length;
    output [7:0]            pcm_udp_payload_axis_tdata;
    output reg              pcm_udp_payload_axis_tvalid;
    input                   pcm_udp_payload_axis_tready;
    output                  pcm_udp_payload_axis_tlast;
    output [23:0]           pcm_udp_tx_left;
    input                   pcm_udp_tx_start;
    input [23:0]            pcm_udp_tx_total;
    input [7:0]             pcm_udp_tx_th;
    input [7:0]             pcm_udp_channel_choose;
    input [7:0]             pcm_udp_capture_sep;
    reg                     pcm_udp_tx_start_d, pcm_udp_tx_start_dd;
    reg [23:0]              pcm_udp_tx_total_reg;
    wire                    pcm_out_valid;
    wire                    pcm_out_ready;
    reg                     pcm_out_lo;
    wire [15:0]             pcm_out;
    wire [pcmaw-1:0]        pcm_available;
    reg [9:0]               pcm_udp_tx_num;
    reg [2:0]               pcm_udp_tx_idx;
    pcmmux_fifo #(CHANNEL, pcmaw)
    pcmmux_fifo_inst(
    //clock and reset
    .pcm_in_clk             (pcm_in_clk),
    .pcm_out_clk            (clk),
    .rst                    (rst || pcm_udp_tx_total_reg==0),

    //pcm input and output
    .pcm_in_valid           (pcm_in_valid),
    .pcm_in_ready           (),
    .pcm_in                 (pcm_in),
    .pcm_out_valid          (pcm_out_valid),
    .pcm_out_ready          (pcm_out_ready),
    .pcm_out                (pcm_out),

    //register access
    .pcm_channel_choose     (pcm_udp_channel_choose),
    .pcm_available          (pcm_available),
    .pcm_capture_sep        (pcm_udp_capture_sep)
    );
    assign pcm_udp_payload_axis_tdata = (pcm_udp_tx_idx == 0) ? pcm_udp_channel_choose :
                                       ((pcm_udp_tx_idx == 1) ? PCM_UDP_PACKET_TYPE :
                                       ((pcm_udp_tx_idx == 2) ? {6'b0, pcm_udp_tx_num[9:8]} :
                                       ((pcm_udp_tx_idx == 3) ? pcm_udp_tx_num[7:0] :
                                        (pcm_out_lo ? pcm_out[7:0] : pcm_out[15:8]))));
    assign pcm_udp_length = (pcm_udp_tx_num + 6) << 1;
    assign pcm_udp_payload_axis_tlast = (pcm_udp_tx_num==1) && pcm_udp_payload_axis_tready && pcm_out_lo && pcm_udp_payload_axis_tvalid;
    assign pcm_out_ready = (pcm_udp_payload_axis_tvalid & pcm_udp_payload_axis_tready & pcm_out_lo && pcm_udp_tx_idx >=4);
    assign pcm_udp_tx_left = pcm_udp_tx_total_reg;
    always @(posedge clk)
    if (rst)
        pcm_out_lo <= #1 1'b0;
    else
        if (pcm_udp_payload_axis_tvalid & pcm_udp_payload_axis_tready)
            pcm_out_lo <= #1 !pcm_out_lo;
    always @(posedge clk)
    if (rst)
    begin
        pcm_udp_tx_start_d <= #1 1'b0;
        pcm_udp_tx_start_dd <= #1 1'b0;
    end
    else
    begin
        pcm_udp_tx_start_d <= #1 pcm_udp_tx_start;
        pcm_udp_tx_start_dd <= #1 pcm_udp_tx_start_d;
    end
    always @(posedge clk)
    if (rst)
        pcm_udp_tx_total_reg <= #1 0;
    else
        if (pcm_udp_tx_start_d & !pcm_udp_tx_start_dd)
            pcm_udp_tx_total_reg <= #1 pcm_udp_tx_total > pcm_udp_tx_num ? pcm_udp_tx_total :pcm_udp_tx_num;
        else
            if (pcm_out_ready && pcm_udp_tx_total_reg!=24'hffffff)
                pcm_udp_tx_total_reg <= #1 (pcm_udp_tx_total_reg != 0) ? pcm_udp_tx_total_reg - 1 : 0;
    //states for block tx_udp
    reg		tx_udp_00;
    reg		tx_udp_01;
    reg		tx_udp_02;
    reg		tx_udp_03;
    reg		tx_udp_04;
    reg		tx_udp_05;
    reg		tx_udp_06;
    reg		tx_udp_07;
    reg		tx_udp_08;
    reg		tx_udp_09;


//state transition for block tx_udp
    always @(posedge clk)
    if (rst)
        tx_udp_00 <= #1 1;
    else
        tx_udp_00 <= #1 tx_udp_09&&pcm_udp_payload_axis_tlast;

    always @(posedge clk)
    if (rst)
        tx_udp_01 <= #1 0;
    else
        tx_udp_01 <= #1 tx_udp_01&&(pcm_udp_tx_total_reg==0) || tx_udp_00&&(pcm_udp_tx_total_reg==0);

    always @(posedge clk)
    if (rst)
        tx_udp_02 <= #1 0;
    else
        tx_udp_02 <= #1 tx_udp_01&&(pcm_udp_tx_total_reg!=0) || tx_udp_00&&(pcm_udp_tx_total_reg!=0);

    always @(posedge clk)
    if (rst)
        tx_udp_03 <= #1 0;
    else
        tx_udp_03 <= #1 tx_udp_03&&(pcm_available < pcm_udp_tx_th) || tx_udp_02&&(pcm_available < pcm_udp_tx_th);

    always @(posedge clk)
    if (rst)
        tx_udp_04 <= #1 0;
    else
        tx_udp_04 <= #1 tx_udp_03&&(pcm_available>=pcm_udp_tx_th) || tx_udp_02&&(pcm_available>=pcm_udp_tx_th);

    always @(posedge clk)
    if (rst)
        tx_udp_05 <= #1 0;
    else
        tx_udp_05 <= #1 tx_udp_04;

    always @(posedge clk)
    if (rst)
        tx_udp_06 <= #1 0;
    else
        tx_udp_06 <= #1 tx_udp_06&&!pcm_udp_hdr_ready || tx_udp_05&&!pcm_udp_hdr_ready;

    always @(posedge clk)
    if (rst)
        tx_udp_07 <= #1 0;
    else
        tx_udp_07 <= #1 tx_udp_06&&pcm_udp_hdr_ready || tx_udp_05&&pcm_udp_hdr_ready;

    always @(posedge clk)
    if (rst)
        tx_udp_08 <= #1 0;
    else
        tx_udp_08 <= #1 tx_udp_08&&(pcm_udp_tx_idx !=4) || tx_udp_07;

    always @(posedge clk)
    if (rst)
        tx_udp_09 <= #1 0;
    else
        tx_udp_09 <= #1 tx_udp_09&&!pcm_udp_payload_axis_tlast || tx_udp_08&&(pcm_udp_tx_idx==4);


    always @(posedge clk)
        if (rst)
            pcm_udp_hdr_valid <= #1 1'b0;
        else
        begin
            if (tx_udp_04)
                pcm_udp_hdr_valid <= #1 1'b1;
            if (tx_udp_06&&pcm_udp_hdr_ready || tx_udp_05&&pcm_udp_hdr_ready)
                pcm_udp_hdr_valid <= #1 1'b0;
        end

    always @(posedge clk)
        if (rst)
            pcm_udp_payload_axis_tvalid <= #1 1'b0;
        else
        begin
            if (tx_udp_06&&pcm_udp_hdr_ready || tx_udp_05&&pcm_udp_hdr_ready)
                pcm_udp_payload_axis_tvalid <= #1 1'b1;
            if (tx_udp_09&&pcm_udp_payload_axis_tlast)
                pcm_udp_payload_axis_tvalid <= #1 1'b0;
        end

    always @(posedge clk)
        if (rst)
            pcm_udp_tx_idx <= #1 0;
        else
        begin
            if (pcm_udp_payload_axis_tready&&tx_udp_08&&(pcm_udp_tx_idx !=4) || tx_udp_07&&pcm_udp_payload_axis_tready)
                pcm_udp_tx_idx <= #1 pcm_udp_tx_idx + 1'b1;
            if (tx_udp_09&&pcm_udp_payload_axis_tlast)
                pcm_udp_tx_idx <= #1 0;
        end

    always @(posedge clk)
        if (rst)
            pcm_udp_tx_num <= #1 0;
        else
        begin
            if (tx_udp_03&&(pcm_available>=pcm_udp_tx_th) || tx_udp_02&&(pcm_available>=pcm_udp_tx_th))
                pcm_udp_tx_num <= #1 (pcm_available > 660) ? 660 : ((pcm_available > pcm_udp_tx_total_reg) ? pcm_udp_tx_total_reg :  pcm_available);
            if ((pcm_udp_payload_axis_tready && pcm_out_lo)&&tx_udp_09&&!pcm_udp_payload_axis_tlast || tx_udp_08&&(pcm_udp_tx_idx==4)&&(pcm_udp_payload_axis_tready && pcm_out_lo))
                pcm_udp_tx_num <= #1 pcm_udp_tx_num - 1'b1;
            if (tx_udp_09&&pcm_udp_payload_axis_tlast)
                pcm_udp_tx_num <= #1 0;
        end

endmodule
