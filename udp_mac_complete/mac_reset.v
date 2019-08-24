`timescale 1ns / 1ps
module mac_reset (
    clk,
    rst,
    set_1000,
    rst_writedata,
    rst_readdata,
	rst_addr,
	rst_rd,
	rst_wr,
	reg_busy,
	rst_finish
);
    parameter REAL_PHY = 0;
    localparam FINISH = 29;
    input               clk;
    input               rst;
    input               set_1000;
    output reg [31:0]   rst_writedata;
    input [31:0]        rst_readdata;
    output reg [7:0]    rst_addr;
    output reg          rst_rd;
    output reg          rst_wr;
    input               reg_busy;
    output reg          rst_finish;
    reg                 reg_busy_d;
    reg                 rw_idx_inc;
    reg [5:0]           rw_idx;
    wire [5:0]          rw_idx_next;
    wire                reset;
    reg                 set_1000_d;
    assign reset = rst | (set_1000 != set_1000_d);
    always @(posedge clk)
	    set_1000_d <= #1 set_1000;
    always @(posedge clk) 
    if (reset)
        reg_busy_d <= 1'b0;
    else
        reg_busy_d <= reg_busy;
    always @(posedge clk)
    if (reset)
		rw_idx <= #1 0;
	else
        rw_idx <= #1 rw_idx_next;
    assign rw_idx_next = (reg_busy == 1'b 0 && reg_busy_d == 1'b1 && !rst_finish) ? rw_idx + rw_idx_inc : rw_idx;
    always @(posedge clk)
    begin
        if (reset)
        begin
            rst_addr <= #1 8'd1; rst_writedata <= #1 0;
        end
        else
        if ((reg_busy == 1'b 0 && reg_busy_d == 1'b1))
        case (rw_idx_next)
        1:  begin rst_addr <= #1 8'd3;     rst_writedata <= #1 32'h06150910; end //mac address
        2:  begin rst_addr <= #1 8'd4;     rst_writedata <= #1 32'h2019; end //mac address
        3:  begin rst_addr <= #1 8'd9;     rst_writedata <= #1 500; end //tx section empty
        4:  begin rst_addr <= #1 8'd10;    rst_writedata <= #1 0; end //tx section full
        5:  begin rst_addr <= #1 8'd7;     rst_writedata <= #1 4000; end //rx section empty
        6:  begin rst_addr <= #1 8'd8;     rst_writedata <= #1 0; end //rx section full
        7:  begin rst_addr <= #1 8'd11;    rst_writedata <= #1 8; end //rx almost empty
        8:  begin rst_addr <= #1 8'd12;    rst_writedata <= #1 8; end //rx almost full
        9:  begin rst_addr <= #1 8'd13;    rst_writedata <= #1 8; end //tx almost empty
        10: begin rst_addr <= #1 8'd14;    rst_writedata <= #1 3; end //tx almost full
        11: begin rst_addr <= #1 8'd15;    rst_writedata <= #1 32'h10; end //set mdio phy addr
        12: begin
                rst_addr <= #1 REAL_PHY ? 8'h84 : 1;
                rst_writedata <= #1 1;
            end //Phy Disable 10M & 100M Advertisement, No parse
        13: begin
                rst_addr <= #1 REAL_PHY ? 8'h89 : 1;
                rst_writedata <= #1 32'h0c00;
            end //0c00 means Master mode, Disable 1000M Advertisement
        14: begin
                rst_addr <= #1 REAL_PHY ? 8'h90 : 1;
                rst_writedata <= #1 32'ha078;
            end //A000 means set FIFO to 24b, 0060 means enable crossover
        15: begin
                rst_addr <= #1 REAL_PHY ? 8'h94 : 1;
                rst_writedata <= #1 32'h0ce2;
            end //80 means add Rx clk delay, 2 means add Tx clk delay
        16: begin
                rst_addr <= #1 REAL_PHY ? 8'h9b : 1;
                rst_writedata <= #1 32'h848b;
            end //b means RGMII to Copper
        17: begin
                rst_addr <= #1 REAL_PHY ? 8'h80 : 1;
                rst_writedata <= #1 set_1000 ? 32'h8140 : 32'ha100;
            end //1000M duplex, reset phy
        FINISH: begin rst_addr <= #1 8'd2; rst_writedata = 32'h04002030 | (set_1000 << 3); end //command, reset, disable Tx & Rx
        FINISH+1: begin rst_addr <= #1 8'd2; rst_writedata = 32'h04000033 | (set_1000 << 3); end //command, discard err pkt, enable Tx & Rx
        FINISH+2: begin rst_addr <= #1 8'd2; rst_writedata = 32'h04000033 | (set_1000 << 3); end //command, discard err pkt, enable Tx & Rx
        default: begin rst_addr <= #1 8'd1; rst_writedata = 0; end
        endcase
    end
    //states for block reg_write
    reg		reg_write_00;
    reg		reg_write_01;
    reg		reg_write_02;
    reg		reg_write_03;
    reg		reg_write_04;
    reg		reg_write_05;
    reg		reg_write_06;


//state transition for block reg_write
    always @(posedge clk)
    if (reset)
        reg_write_00 <= #1 1;
    else
        reg_write_00 <= #1 reg_write_06&&!rst_finish;

    always @(posedge clk)
    if (reset)
        reg_write_01 <= #1 0;
    else
        reg_write_01 <= #1 reg_write_01&&(rw_idx_next != FINISH + 1) || reg_write_00;

    always @(posedge clk)
    if (reset)
        reg_write_02 <= #1 0;
    else
        reg_write_02 <= #1 reg_write_01&&(rw_idx_next==FINISH + 1);

    always @(posedge clk)
    if (reset)
        reg_write_03 <= #1 0;
    else
        reg_write_03 <= #1 reg_write_03&&!(reg_busy == 1'b 0 && reg_busy_d == 1'b1 && !rst_readdata[13]) || reg_write_02&&!(reg_busy == 1'b 0 && reg_busy_d == 1'b1 && !rst_readdata[13]);

    always @(posedge clk)
    if (reset)
        reg_write_04 <= #1 0;
    else
        reg_write_04 <= #1 reg_write_04&&(rw_idx_next < FINISH + 2) || reg_write_03&&(reg_busy == 1'b 0 && reg_busy_d == 1'b1 && !rst_readdata[13]) || reg_write_02&&(reg_busy == 1'b 0 && reg_busy_d == 1'b1 && !rst_readdata[13]);

    always @(posedge clk)
    if (reset)
        reg_write_05 <= #1 0;
    else
        reg_write_05 <= #1 reg_write_04&&(rw_idx_next>=FINISH + 2);

    always @(posedge clk)
    if (reset)
        reg_write_06 <= #1 0;
    else
        reg_write_06 <= #1 reg_write_06&&rst_finish || reg_write_05;


    always @(posedge clk)
        if (reset)
            rst_finish <= #1 1'b0;
        else
        begin
            if (reg_write_04&&(rw_idx_next>=FINISH + 2))
                rst_finish <= #1 1'b1;
        end

    always @(posedge clk)
        if (reset)
            rst_rd <= #1 1'b0;
        else
        begin
            if (reg_write_01&&(rw_idx_next==FINISH + 1))
                rst_rd <= #1 1'b1;
            if (reg_write_03&&(reg_busy == 1'b 0 && reg_busy_d == 1'b1 && !rst_readdata[13]) || reg_write_02&&(reg_busy == 1'b 0 && reg_busy_d == 1'b1 && !rst_readdata[13]))
                rst_rd <= #1 1'b0;
        end

    always @(posedge clk)
        if (reset)
            rst_wr <= #1 1'b0;
        else
        begin
            if (reg_write_00)
                rst_wr <= #1 1;
            if (reg_write_01&&(rw_idx_next==FINISH + 1))
                rst_wr <= #1 1'b0;
            if (reg_write_03&&(reg_busy == 1'b 0 && reg_busy_d == 1'b1 && !rst_readdata[13]) || reg_write_02&&(reg_busy == 1'b 0 && reg_busy_d == 1'b1 && !rst_readdata[13]))
                rst_wr <= #1 1'b1;
            if (reg_write_04&&(rw_idx_next>=FINISH + 2))
                rst_wr <= #1 1'b0;
        end

    always @(posedge clk)
        if (reset)
            rw_idx_inc <= #1 1;
        else
        begin
            if (reg_write_01&&(rw_idx_next==FINISH + 1))
                rw_idx_inc <= #1 0;
            if (reg_write_03&&(reg_busy == 1'b 0 && reg_busy_d == 1'b1 && !rst_readdata[13]) || reg_write_02&&(reg_busy == 1'b 0 && reg_busy_d == 1'b1 && !rst_readdata[13]))
                rw_idx_inc <= #1 1;
        end

endmodule
