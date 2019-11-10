`timescale 1ns / 1ps

module test_mf2_dac2;

parameter CHANNEL=2;
parameter FREQ_NUM = 2;
parameter MIX_NUM = 1;
parameter pcmaw = 10;

    //reset and clock
    reg                                 rst;
    reg                                 clk1;
    reg                                 ad_clk;
    reg                                 clk_2;
    reg                                 da_clk;

    //iq pcm input
    wire [16*FREQ_NUM-1:0]              sc_ipcm_out, sc_qpcm_out;
    wire                                sc_iqpcm_valid;
    wire                                sc_ad_valid;

    //da pcm output
    wire [CHANNEL-1:0]                  dac_pcm_out_valid;
    wire [16*CHANNEL-1:0]               dac_pcm_out;

    //dac controller
    reg [16*MIX_NUM*CHANNEL-1:0]        cos_sita, sin_sita;
    reg [4*MIX_NUM*CHANNEL-1:0]         choose;

    //mixer output
    wire [32*CHANNEL*FREQ_NUM-1:0]      ipcm_acc_out;
    wire [32*CHANNEL*FREQ_NUM-1:0]      qpcm_acc_out;

    //sincos gen controller
    reg [16*FREQ_NUM-1:0]               sc_sin_length;
    reg                                 resync;

    //register access
    reg [16:0]                          reg_addr;
    reg                                 reg_wr;
    wire                                reg_ready;
    reg [31:0]                          reg_writedata;
    
    //internal reg
    reg [31:0]                          sin_tbl[2047:0];
    integer                             i,j,k;
    
    sincos_gen #(
    .FREQ_NUM                           (FREQ_NUM),
    .pcmaw                              (pcmaw)
    ) sincos_gen_inst(
    //clock and reset
    .da_clk                             (da_clk),
    .rst                                (rst),

    //pcm input and output
    .sc_iqpcm_valid                     (sc_iqpcm_valid),
    .sc_ipcm_out                        (sc_ipcm_out),
    .sc_qpcm_out                        (sc_qpcm_out),
    .sc_ad_valid                        (sc_ad_valid),

    //register access
    .clk_2                              (clk_2),
    .reg_addr                           (reg_addr),
    .reg_rd                             (1'b0),
    .reg_wr                             (reg_wr),
    .reg_ready                          (reg_ready),
    .reg_writedata                      (reg_writedata),
    .reg_readdata                       (),

    //controller
    .sc_sin_length                      (sc_sin_length),
    .sc_cic_rate                        ({FREQ_NUM{4'd0}}),
    .sc_resync                          (resync),
    .sc_status                          (),
    .sc_err                             ()
    );
    
    mix_freq2_mc #(
    .FREQ_NUM                           (FREQ_NUM),
    .CHANNEL                            (CHANNEL)
    ) mix_freq2_mc_inst (
    //reset and clock
    .rst                                (rst),
    .clk1                               (clk1),
    .ad_clk                             (ad_clk),

    //pcm input
    .ad_pcm_in_valid                    ({CHANNEL{1'b0}}),
    .ad_pcm_in                          (),
    .da_lb_pcm_in_valid                 (dac_pcm_out_valid),
    .da_lb_pcm_in                       (dac_pcm_out),

    //iq pcm input
    .ipcm_in                            (sc_ipcm_out),
    .qpcm_in                            (sc_qpcm_out),
    .ad_valid                           (sc_ad_valid),
    .ipcm_acc_out                       (ipcm_acc_out),
    .qpcm_acc_out                       (qpcm_acc_out),

    //controller
    .choose_lb                          ({FREQ_NUM{1'b1}}),
    .acc_shift                          ({FREQ_NUM{4'd12}}),
    .cycle_num                          ({24*FREQ_NUM{1'b0}})
    );

    dac_tx2 #(
    .CHANNEL                            (CHANNEL),
    .FREQ_NUM                           (FREQ_NUM),
    .MIX_NUM                            (MIX_NUM)
    )  dac_tx2_inst(
    //reset and clock
    .rst                                (rst),
    .clk1                               (clk1),
    .da_clk                             (da_clk),

    //iq pcm input
    .ipcm_in                            (sc_ipcm_out),
    .qpcm_in                            (sc_qpcm_out),
    .iqpcm_valid                        (sc_iqpcm_valid),

    //da pcm output
    .dac_pcm_out_valid                  (dac_pcm_out_valid),
    .dac_pcm_out                        (dac_pcm_out),

    //controller input
    .cos_sita                           (cos_sita),
    .sin_sita                           (sin_sita),
    .choose                             (choose)
    );
    
    always
    begin
        clk1 <= 1'b 1;
        #5;
        clk1 <= 1'b 0;
        #5;
    end

    always
    begin
        clk_2 <= 1'b 1;
        #10;
        clk_2 <= 1'b 0;
        #10;
    end
    
    always
    begin
        da_clk <= 1'b 1;
        #10;
        da_clk <= 1'b 0;
        #10;
    end

    always
    begin
        ad_clk <= 1'b 1;
        #20;
        ad_clk <= 1'b 0;
        #20;
    end
    
    initial
    begin
        rst = 0;
        @(posedge clk1);
        rst = 1;
        #100;
        resync = 1'b0;
        sc_sin_length = 0;
        reg_wr = 0;
        reg_addr = 0;
        reg_writedata = 0;
        cos_sita = {MIX_NUM*CHANNEL{16'h0}};
        sin_sita = {MIX_NUM*CHANNEL{16'h1000}};
        choose = {MIX_NUM*CHANNEL{4'd0}};
        
        //read sin table
        $readmemh("../testbench/sincos_tb.txt", sin_tbl);
        for (j=0; j<2048; j=j+1)
        if (sin_tbl[j] === 32'hxxxxxxxx)
        begin
            k = j;
            j = 2048;
        end
        
        @(posedge clk_2);
        rst = 0;
        reg_wr <= #1 1;
        for (i=0; i<FREQ_NUM; i=i+1)
        for (j=0; j<k; j=j+1)
        begin            
            reg_addr <= #1 (i << 14) + j;
            reg_writedata <= #1 sin_tbl[j];
            @(posedge clk_2);
            while (!reg_ready)
                @(posedge clk_2);
        end
        reg_wr <= #1 0;
        k = k-1;        
        sc_sin_length <= #1 (sin_tbl[k][15:0] == 16'd0) ? 2 * k : 2 * k+1;
        @(posedge clk_2);
        $display("sin_length=%d", sc_sin_length);
        resync <= #1 1'b1;
        @(posedge clk_2);
        resync <= #1 1'b0;
        #10000;
        $display("ia=%x, qa=%x", ipcm_acc_out[31:0], qpcm_acc_out[31:0]);
        $stop;
    end
endmodule