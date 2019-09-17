`timescale 1 ns / 1 ps

module test_mix_freq;
parameter CHANNEL=1;
parameter pcmaw = 10;
    reg                     pcm_clk;
    reg                     clk1;
    reg                     clk_2;
    reg                     rst;

    wire [CHANNEL-1:0]      ad_pcm_in_valid;
    wire [CHANNEL-1:0]      ad_pcm_in_ready;
    wire [16*CHANNEL-1:0]   ad_pcm_in;
    reg [15:0]              reg_addr;
    reg                     reg_wr_source;
    reg                     reg_wr_mf;
    wire                    reg_ready;
    reg [31:0]              reg_writedata;
    reg [pcmaw-1:0]         signal_len;
    reg                     resync;
    reg [pcmaw-1:0]         sin_len;
    
    wire [CHANNEL-1:0]      ipcm_dec_out_valid;
    wire [16*CHANNEL-1:0]   ipcm_dec_out;
    wire [32*CHANNEL-1:0]   ipcm_acc_out;
    wire [CHANNEL-1:0]      qpcm_dec_out_valid;
    wire [16*CHANNEL-1:0]   qpcm_dec_out;
    wire [32*CHANNEL-1:0]   qpcm_acc_out;
    wire [CHANNEL-1:0]      iqpcm_dump_valid;
    wire [16*CHANNEL-1:0]   iqpcm_dump;

    //internal reg
    integer                 i, j, k, fi, fq, fiq;
    reg [31:0]              sin_tbl[2047:0];

    source_mem #(
    .CHANNEL                (CHANNEL),
    .pcmaw                  (pcmaw)
    ) source_mem_inst (
    //clock and reset
    .pcm_clk                (pcm_clk),
    .rst                    (rst),

    //pcm input and output
    .pcm_out_valid          (ad_pcm_in_valid),
    .pcm_out_ready          (ad_pcm_in_ready),
    .pcm_out                (ad_pcm_in),

    //register access
    .clk_2                  (clk_2),
    .reg_addr               (reg_addr),
    .reg_rd                 (1'b0),
    .reg_wr                 (reg_wr_source),
    .reg_ready              (reg_ready),
    .reg_writedata          (reg_writedata),
    .reg_readdata           (),
    .signal_len             ({CHANNEL{signal_len}})
    );

    mix_freq_mc #(
    .CHANNEL                (CHANNEL),
    .pcmaw                  (pcmaw)
    ) mix_freq_mc_inst (
    //reset and clock
    .rst                    (rst),
    .clk1                   (clk1),
    .pcm_clk                (pcm_clk),

    //pcm input
    .ad_pcm_in_valid        (ad_pcm_in_valid),
    .ad_pcm_in_ready        (ad_pcm_in_ready),
    .ad_pcm_in              (ad_pcm_in),
    .da_lb_pcm_in_valid     (ad_pcm_in_valid),
    .da_lb_pcm_in_ready     (ad_pcm_in_ready),
    .da_lb_pcm_in           (ad_pcm_in),

    //iq pcm output
    .ipcm_dec_out_valid     (ipcm_dec_out_valid),
    .ipcm_dec_out_ready     ({CHANNEL{1'b1}}),
    .ipcm_dec_out           (ipcm_dec_out),
    .ipcm_acc_out           (ipcm_acc_out),
    .qpcm_dec_out_valid     (qpcm_dec_out_valid),
    .qpcm_dec_out_ready     ({CHANNEL{1'b1}}),
    .qpcm_dec_out           (qpcm_dec_out),
    .qpcm_acc_out           (qpcm_acc_out),
    .iqpcm_dump_valid       (iqpcm_dump_valid),
    .iqpcm_dump             (iqpcm_dump),

    //register access
    .clk_2                  (clk_2),
    .reg_addr               ({4'd0, reg_addr[11:0]}),
    .reg_rd                 (1'b0),
    .reg_wr                 (reg_wr_mf),
    .reg_ready              (reg_ready),
    .reg_writedata          (reg_writedata),
    .reg_readdata           (),

    //controller input
    .pcm_out_shift          (4'd0),
    .choose_lb              ({CHANNEL{1'b1}}),
    .dec_rate               (8'd0),
    .dec_rate2              (8'd0),
    .acc_shift              (4'd0),
    .sin_length             (sin_len),
    .resync                 (resync)
    );

    always @(posedge pcm_clk)
    if (ipcm_dec_out_valid)
        $fdisplay(fi, "%x", ipcm_dec_out);

    always @(posedge pcm_clk)
    if (qpcm_dec_out_valid)
        $fdisplay(fq, "%x", qpcm_dec_out);

    always @(posedge pcm_clk)
    if (iqpcm_dump_valid)
        $fdisplay(fiq, "%x", iqpcm_dump);

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
        pcm_clk <= 1'b 1;
        #20;
        pcm_clk <= 1'b 0;
        #20;
    end


    initial
    begin
        rst = 0;
        fi = $fopen("../testbench/ipcm.txt","w");
        fq = $fopen("../testbench/qpcm.txt","w");
        fiq = $fopen("../testbench/iqpcm.txt","w");
        @(posedge clk1);
        rst = 1;
        #100;
        resync = 0;
        signal_len = 0;
        reg_wr_mf = 0;
        reg_wr_source = 0;
        reg_addr = 0;
        reg_writedata = 0;
        sin_len = 0;
        //read sin table
        $readmemh("../testbench/sin_tb.txt", sin_tbl);
        for (j=0; j<2048; j=j+1)
        if (sin_tbl[j] === 32'hxxxxxxxx)
        begin
            k = j;
            j = 2048;
        end
        @(posedge clk_2);
        rst = 0;
        reg_wr_mf <= #1 1;
        for (i=0; i<CHANNEL; i=i+1)
        for (j=0; j<k; j=j+1)
        begin            
            reg_addr <= #1 (i << 12) + j;
            reg_writedata <= #1 sin_tbl[j];
            @(posedge clk_2);
            while (!reg_ready)
                @(posedge clk_2);
        end
        reg_wr_mf <= #1 0;
        sin_len <= (k-1) << 1;
        
        //read source table
        $readmemh("../testbench/pcm_source.txt", sin_tbl);
        for (j=0; j<2048; j=j+1)
        if (sin_tbl[j] === 32'hxxxxxxxx)
        begin
            k = j;
            j = 2048;
        end
        @(posedge clk_2);
        rst = 0;
        reg_wr_source <= #1 1;
        for (i=0; i<CHANNEL; i=i+1)
        for (j=0; j<k; j=j+1)
        begin            
            reg_addr <= #1 (i << 12) + j;
            reg_writedata <= #1 sin_tbl[j];
            @(posedge clk_2);
            while (!reg_ready)
                @(posedge clk_2);
        end
        reg_wr_source <= #1 0;
        @(posedge pcm_clk);
        resync <= #1 1;
        @(posedge pcm_clk);
        //start
        resync <= #1 0;
        signal_len <= #1 ((k-1) << 1);
        
        #6000;
        $display("iacc=%x,qacc=%x",ipcm_acc_out, qpcm_acc_out);
        $fclose(fi);
        $fclose(fq);
        $fclose(fiq);
        $stop;
    end
endmodule