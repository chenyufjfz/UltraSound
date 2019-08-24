`timescale 1 ns / 1 ps

module test_pcm2usb;
parameter pcmaw = 10;
    reg                     pcm_clk;
    reg                     clk;
    reg                     rst;

    wire                    pcm_out_valid;
    reg                     pcm_out_ready;
    wire [15:0]             pcm_out;

    reg                     clk_2;
    reg [15:0]              reg_addr;
    reg                     reg_rd;
    reg                     reg_wr;
    wire                    reg_ready;
    reg [31:0]              reg_writedata;
    wire [31:0]             reg_readdata;
    reg [pcmaw-1:0]         signal_len;
    reg                     dac_run;
    reg                     pcm_udp_tx_start;

    //UDP frame output
    wire                    pcm_udp_hdr_valid;
    wire [15:0]             pcm_udp_length;
    wire [7:0]              pcm_udp_payload_axis_tdata;
    wire                    pcm_udp_payload_axis_tvalid;
    wire                    pcm_udp_payload_axis_tlast;

    reg [31:0]              pcm_source[2047:0];
    reg [7:0]               pcm_sink[4096:0];
    integer                 i, j;

    dac_tx #(
    .CHANNEL                (1),
    .pcmaw                  (pcmaw)
    ) dac_tx_inst(
    //clock and reset
    .pcm_clk                (pcm_clk),
    .rst                    (rst),

    //pcm input and output
    .dac_pcm_out_valid      (pcm_out_valid),
    .dac_pcm_out_ready      (pcm_out_ready),
    .dac_pcm_out            (pcm_out),

    //register access
    .clk_2                  (clk_2),
    .reg_addr               (reg_addr),
    .reg_rd                 (reg_rd),
    .reg_wr                 (reg_wr),
    .reg_ready              (reg_ready),
    .reg_writedata          (reg_writedata),
    .reg_readdata           (reg_readdata),

    .dac_signal_len         (signal_len),
    .dac_cic_rate           (0),
    .dac_run                (dac_run)
    );    

    pcm2udp#(
    .CHANNEL                (1),
    .pcmaw                  (pcmaw)
    ) pcm2udp_inst(
    //clock and reset
    .pcm_in_clk             (pcm_clk),
    .clk                    (clk),
    .rst                    (rst),

    //pcm input and output
    .pcm_in_valid           (pcm_out_valid),
    .pcm_in                 (pcm_out),

    //UDP frame output
    .pcm_udp_hdr_valid      (pcm_udp_hdr_valid),
    .pcm_udp_hdr_ready      (1'b1),
    .pcm_udp_length         (pcm_udp_length),
    .pcm_udp_payload_axis_tdata     (pcm_udp_payload_axis_tdata),
    .pcm_udp_payload_axis_tvalid    (pcm_udp_payload_axis_tvalid),
    .pcm_udp_payload_axis_tready    (1'b1),
    .pcm_udp_payload_axis_tlast     (pcm_udp_payload_axis_tlast),

    //regiser access
    .pcm_udp_tx_start       (pcm_udp_tx_start),
    .pcm_udp_tx_total       (320),
    .pcm_udp_tx_th          (64),
    .pcm_udp_channel_choose (0),
    .pcm_udp_capture_sep    (0)
);

always
begin
    clk <= 1'b 1;
    #5;
    clk <= 1'b 0;
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
    j = 0;
    dac_run = 0;
    @(posedge clk);
    rst = 1;
    #100;
    reg_rd = 0;
    reg_wr = 0;
    reg_addr = 0;
    pcm_out_ready = 1;
    pcm_udp_tx_start = 0;
    $readmemh("../testbench/pcm_source.txt", pcm_source);
    for (i=0; i<2048; i=i+1)
    if (pcm_source[i] === 32'hxxxxxxxx)
    begin
        signal_len = i * 2;
        i = 2048;
    end
    reg_writedata = pcm_source[0];
    
    @(posedge clk_2);
    rst = 0;
    for (i=0; i<signal_len /2 ; i=i+1)
    begin
        reg_wr <= #1 1;
        reg_addr <= #1 i;
        reg_writedata <= #1 pcm_source[i];
        @(posedge clk_2);
        while (!reg_ready)
            @(posedge clk_2);
    end

    reg_wr <= #1 0;
    pcm_udp_tx_start <= #1 1;
    @(posedge clk_2);
    pcm_udp_tx_start <= #1 0;
    dac_run <= #1 1;
    @(posedge clk_2);
    
    for (i=0; i<5; i=i+1)
    begin
        while (pcm_udp_hdr_valid==0)
            @(posedge clk);
        $display("packet lenght = %d", pcm_udp_length);
        while (pcm_udp_payload_axis_tlast==0)
        begin
            if (pcm_udp_payload_axis_tvalid)
            begin
                pcm_sink[j] <= #1 pcm_udp_payload_axis_tdata;
                j = j+1;
            end
            @(posedge clk);
        end 
        if (pcm_udp_payload_axis_tvalid)
        begin
            pcm_sink[j] <= #1 pcm_udp_payload_axis_tdata;
            j = j+1;
        end       
    end
    
    $writememh("../testbench/pcm_sink.txt", pcm_sink);
    $stop;
end
endmodule