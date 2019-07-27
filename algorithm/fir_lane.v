`timescale 1ns / 1ps

module fir_lane
(
    //reset and clock
    rst,
    clk1,
    pcm_clk,

    //pcm inout which is pcm_clk domain
    pcm_in_wr,
    pcm_in,
    pcm_in_address,
    pcm_out,

    //param input which is clk1 domain
    param_q,
    param_addr,

    //control which is pcm_clk domain
    pcm_out_shift,
    fir_start,
    tap_len
);
parameter gen_param_addr = 1;
parameter acw = 30; //affect accuracy, max is 32


    //reset and clock
    input               rst;
    input               clk1;
    input               pcm_clk;

    //pcm inout
    input               pcm_in_wr;
    input [15:0]        pcm_in;
    input [8:0]         pcm_in_address;
    output [15:0]       pcm_out;

    //param input
    input [31:0]        param_q;
    output reg [7:0]    param_addr;

    //control
    input [3:0]         pcm_out_shift;
    input               fir_start;
    input [7:0]         tap_len;
    
    //internal
    reg                 fir_start_d;
    reg [4:0]           clear_acc;    
    reg [7:0]           tap_addr;
    reg [7:0]           tap_addr_end;
    reg [2:0]           odd_align;
    reg [5:0]           pcm_o_ld;
    reg [2:0]           pcm_out_shift_d;

    wire [31:0]         pcm_q;
    reg [15:0]          pcm_qh_d;
    wire [31:0]         pcm_q_align;
    reg [acw-1:0]       acch, accl;
    wire [31:0]         mult_hresult, mult_lresult;
    reg [acw:0]         pcm_o;
    wire [47:0]         pcm_o_48;
    reg [31:0]          pcm_o_32;

//fir_pcm_ram has input and output register, pipeline = 2
fir_pcm_ram fir_pcm_ram_inst(
    .data               (pcm_in),
	.rdaddress          (tap_addr),
	.rdclock            (clk1),
	.wraddress          (pcm_in_address),
	.wrclock            (pcm_clk),
	.wren               (pcm_in_wr),
	.q                  (pcm_q)
);

mult #(
    .di1(16),
    .di2(16),
    .do(32),
    .pipeline(2)        //pipeline=2, means has input and output register
) mult_l(
    .clock              (clk1),
	.dataa              (pcm_q_align[15:0]),
	.datab              (param_q[15:0]),
	.result             (mult_lresult)
);

mult #(
    .di1(16),
    .di2(16),
    .do(32),
    .pipeline(2)
) mult_h(
    .clock              (clk1),
	.dataa              (pcm_q_align[31:16]),
	.datab              (param_q[31:16]),
	.result             (mult_hresult)
);

    always @(posedge clk1)
        pcm_qh_d <= #1 pcm_q[31:16];

    assign pcm_q_align = odd_align[0] ? {pcm_q[15:0], pcm_qh_d} : pcm_q;

    always @(posedge clk1)
    if (rst | clear_acc[0])
        acch <= #1 0;
    else
        acch <= #1 acch + {{7{mult_hresult[31]}}, mult_hresult[31:39-acw]}; //not overflow

    always @(posedge clk1)
    if (rst | clear_acc[0])
        accl <= #1 0;
    else
        accl <= #1 accl + {{7{mult_lresult[31]}}, mult_lresult[31:39-acw]}; //not overflow

    always @(posedge clk1)
    if (pcm_o_ld[0])
        pcm_o <= #1 {acch[acw-1], acch} + {accl[acw-1], accl}; //not overflow


    assign pcm_o_48 = {{(47-acw){pcm_o[acw]}}, pcm_o}; //not overflow

    always @(posedge pcm_clk)
        pcm_o_32 <= #1 pcm_o_48 >> pcm_out_shift_d;

    assign pcm_out = pcm_o_32[31] ?
                    ((pcm_o_32[31:16]==16'hffff) ? pcm_o_32[15:0] : 16'h8000) :
                    ((pcm_o_32[31:16]==16'h0000) ? pcm_o_32[15:0] : 16'h7fff); //saturation handle
                    
    always @(posedge clk1)
    if (rst)
        fir_start_d <= #1 1'b0;
    else
        fir_start_d <= #1 fir_start; 
        
generate
if (gen_param_addr) begin
    always @(posedge clk1)
    if (fir_start & !fir_start_d)
        param_addr <= #1 pcm_in_address[0] ? 0 : ~0;
    else
        param_addr <= #1 param_addr + 1'b1;
end
else
begin
    always @(*)
        param_addr = #1 0;
end
endgenerate                  

    always @(posedge clk1)
    if (fir_start & !fir_start_d)
        pcm_out_shift_d <= #1 (pcm_out_shift + acw - 39 > 0) ? pcm_out_shift + acw - 39 : 0;
        
    always @(posedge clk1)
    if (fir_start & !fir_start_d)
        tap_addr <= #1 pcm_in_address[8:1] - tap_len + pcm_in_address[0];
    else
        tap_addr <= #1 (tap_addr <= tap_addr_end) ? tap_addr + 1'b1 : tap_addr;
    
    always @(posedge clk1)
    if (fir_start & !fir_start_d)
        tap_addr_end <= #1 pcm_in_address[8:1];
        
    always @(posedge clk1)
    if (fir_start & !fir_start_d)
        odd_align <= #1 {!pcm_in_address[0], odd_align[2:1]};
    else
        odd_align <= #1 {odd_align[2], odd_align[2:1]};
    
    always @(posedge clk1)
    if (fir_start & !fir_start_d)
        clear_acc <= #1 pcm_in_address[0] ? {2'b01, clear_acc[3:1]} : {1'b1, clear_acc[4:1]};
    else
        clear_acc <= #1 {1'b0, clear_acc[4:1]};

    always @(posedge clk1)
    if (tap_addr == tap_addr_end)
        pcm_o_ld <= #1 odd_align[2] ? {1'b1, pcm_o_ld[5:1]} : {2'b01, clear_acc[4:1]};
    else
        pcm_o_ld <= #1 {1'b0, pcm_o_ld[5:1]};
endmodule