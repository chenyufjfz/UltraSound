`timescale 1ns / 1ps

module test_fir;
parameter CHANNEL = 3;
parameter FIR_LANE = 16;
parameter acw = 30;
parameter SIMULATION = 0;

    reg                     clk;
    reg                     clk1;
    reg                     rst;

    wire [16*CHANNEL-1:0]   pcm_in;
    reg                     pcm_in_valid;
    wire [CHANNEL-1:0]      pcm_out_valid;
    wire [16*CHANNEL-1:0]   pcm_out;
    
    reg                     clk_2;
    reg [7:0]               reg_addr;
    reg                     reg_rd;
    reg                     reg_wr;
    wire                    reg_ready;
    reg [31:0]              reg_writedata;
    wire [31:0]             reg_readdata;
    
    //internal reg
    reg [15:0]              pcm_in_d;
    reg [7:0]               tap_len;
    integer                 i;
    reg [31:0]              param[255:0];
    reg [16*CHANNEL-1:0]    result[1023: 0];
    integer                 result_idx;
    
    assign pcm_in = {CHANNEL{pcm_in_d}};
always
begin
    clk <= 1'b 1;
    #5;
    clk <= 1'b 0;
    #5;
end

always
begin
    clk1 <= 1'b 1;
    #3;
    clk1 <= 1'b 0;
    #2;
end

always
begin
    clk_2 <= 1'b 1;
    #10;
    clk_2 <= 1'b 0;
    #10;
end

always @(posedge clk)
if (pcm_out_valid)
begin
    result[result_idx] = pcm_out;
    result_idx = result_idx + 1;
end    

fir_mc #(
    .CHANNEL        (CHANNEL),
    .FIR_LANE       (FIR_LANE),
    .acw            (acw),
    .SIMULATION     (SIMULATION)
)   fir_mc_inst
(
    //clock and reset
    .pcm_clk        (clk),
    .clk1           (clk1),
    .rst            (rst),

    //pcm input and output
    .pcm_in_valid   ({CHANNEL{pcm_in_valid}}),
    .pcm_in_ready   (),
    .pcm_in         (pcm_in),
    .pcm_out_valid  (pcm_out_valid),
    .pcm_out_ready  (~0),
    .pcm_out        (pcm_out),

    //register access
    .clk_2          (clk_2),
    .reg_addr       (reg_addr),
    .reg_rd         (reg_rd),
    .reg_wr         (reg_wr),
    .reg_ready      (reg_ready),
    .reg_writedata  (reg_writedata),
    .reg_readdata   (reg_readdata)
);


task automatic generate_pcm_in;
    input integer num;
    input integer sep;
    integer i, j, k;
    
    begin
        pcm_in_valid <= #1 0;
        for (i=0; i<num; i=i+1)
        begin
            for (j=0; j+1<sep; j=j+1)
                @(posedge clk);            
            pcm_in_valid <= #1 1;
            @(posedge clk);
            pcm_in_valid <= #1 0;
            pcm_in_d <= #1 (pcm_in_d + 1 < tap_len * 2) ? pcm_in_d + 1 : 0;
        end
    end
endtask
    
initial
begin
    rst = 0;
    @(posedge clk);
    rst = 1;
    #100;
    reg_rd = 0;
    reg_wr = 0;
    reg_addr = ~0;
    pcm_in_valid = 0;
    pcm_in_d <= 0;
    $readmemh("../testbench/param.txt", param);
    for (i=0; i<256; i=i+1)
    if (param[i] === 32'hxxxxxxxx)
    begin
        tap_len = i;
        i = 256;
    end
    reg_writedata = param[0];
    @(posedge clk_2);
    rst = 0;    
    for (i=0; i<tap_len; i=i+1)
    begin
        reg_wr <= #1 1;
        reg_addr <= #1 i;
        reg_writedata <= #1 param[i];   
        @(posedge clk_2); 
        while (!reg_ready)
            @(posedge clk_2);
    end
    reg_addr <= #1 ~0;
    reg_writedata <= #1 {1'b0, 4'd13, tap_len, 8'd1};
    @(posedge clk_2);
    while (!reg_ready)
        @(posedge clk_2);
    reg_wr <= #1 0;
    
    generate_pcm_in(100, 1);
    result_idx = 0;
    generate_pcm_in(50, 1);
    $writememh("../testbench/fir_mc_out.txt", result);
    $stop;
end
endmodule