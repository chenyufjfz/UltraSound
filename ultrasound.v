`timescale 1ns / 1ps

`define DEV_BOARD

module ultrasound(
    CLOCK_50,
    KEY,
    //////// Ethernet 0 //////////
    ENET0_GTX_CLK,
    ENET0_MDC,
    ENET0_MDIO,
    ENET0_RST_N,
    ENET0_RX_CLK,
    ENET0_RX_DATA,
    ENET0_RX_DV,
    ENET0_TX_DATA,
    ENET0_TX_EN,
    ENET0_CONFIG,

    //ENCODER
    ENCODER_IN,

`ifndef    DEV_BOARD
    //AD interface
    AD_CLK_OUT,
    AD_PCM_IN,
    AD_MODE,

    //DA interface
    DA_CLK_OUT,
    DA_CLK_OUT1,
    DA_PCM_OUT,
    DA_PCM_OUT_T,
    DA_WR,
    DA_WR_T,

    //Gain control
    CH_GAIN_SEL,
    CH_GAIN_DA,
    CH_GAIN_WR,
    CH_GAIN_CLR,
    CH_GAIN_GAIN,
    CH_GAIN_BUF,
    CH_GAIN_LDAC,
    SYN_CLK,
    SYN_SCK,
    SYN_SDATAIN,
    SYN_SDATAOUT,
    SYN_TRIG_START,
    SYN_TRIG_PULSE,
    MODEL_SEL,
    CH_FILTER_SEL,
    CH_EMIT_RECV_EN,
    ENCODER_ERR,
`else
    //status led
    TX_ERR,
    RX_ERR
`endif
);
parameter SIMULATION = 0;
parameter RESET_CTR_WIDTH = SIMULATION ? 5 : 22;
parameter ENET0_RST_CTR_WIDTH = 21;
parameter DAC_CHANNEL = 10;
parameter ADC_CHANNEL = 8;
parameter FREQ_NUM = 5;
parameter pcm2usb_pcmaw = 11;
parameter sintb_aw = 12;
parameter DA_AD_RATE = 8'd2;
parameter MIX_NUM = 5;
`ifdef    DEV_BOARD
parameter REAL_PHY = 32'h1111;
`else
parameter REAL_PHY = 32'h1512;
`endif
localparam DACT_CHANNEL = DAC_CHANNEL - ADC_CHANNEL;

    //clk
    input                               CLOCK_50;
    input [1:0]                         KEY;
    //Ethernet0
    output                              ENET0_GTX_CLK;
    output                              ENET0_MDC;
    inout                               ENET0_MDIO;
    output                              ENET0_RST_N;
    input                               ENET0_RX_CLK;
    input [3:0]                         ENET0_RX_DATA;
    input                               ENET0_RX_DV;
    output [3:0]                        ENET0_TX_DATA;
    output                              ENET0_TX_EN;
    output                              ENET0_CONFIG;

`ifndef    DEV_BOARD
    //AD interface
    output                              AD_CLK_OUT;
    input [16*ADC_CHANNEL-1:0]          AD_PCM_IN;
    output                              AD_MODE;
    //DA interface
    output                              DA_CLK_OUT;
    output                              DA_CLK_OUT1;
    output reg [14*ADC_CHANNEL-1:0]     DA_PCM_OUT;
    output reg [14*DACT_CHANNEL-1:0]    DA_PCM_OUT_T;

    output [ADC_CHANNEL-1:0]            DA_WR;
    output [DACT_CHANNEL-1:0]           DA_WR_T;
    output [2:0]                        CH_GAIN_SEL;
    output [11:0]                       CH_GAIN_DA;
    output                              CH_GAIN_WR;
    output                              CH_GAIN_CLR;
    output                              CH_GAIN_GAIN;
    output                              CH_GAIN_BUF;
    output                              CH_GAIN_LDAC;
    output                              SYN_CLK;
    output                              SYN_SCK;
    input                               SYN_SDATAIN;
    output                              SYN_SDATAOUT;
    output [1:0]                        MODEL_SEL;
    output                              CH_FILTER_SEL;
    output [7:0]                        CH_EMIT_RECV_EN;
    output [1:0]                        ENCODER_ERR;
    output                              SYN_TRIG_START;
    output                              SYN_TRIG_PULSE;
    input [5:0]                         ENCODER_IN;
`else
    //status led
    output                              TX_ERR;
    output                              RX_ERR;
    input [1:0]                         ENCODER_IN;
`endif

    wire [4:0]                          slot_idx;

    // udp_mac_complete tx & rx UDP
    wire                                tx_udp_hdr_valid;
    wire                                tx_udp_hdr_ready;
    wire [31:0]                         tx_udp_ip_dest_ip;
    wire [15:0]                         tx_udp_source_port;
    wire [15:0]                         tx_udp_dest_port;
    wire [15:0]                         tx_udp_length;
    wire [7:0]                          tx_udp_payload_axis_tdata;
    wire                                tx_udp_payload_axis_tvalid;
    wire                                tx_udp_payload_axis_tready;
    wire                                tx_udp_payload_axis_tlast;
    wire                                tx_udp_payload_axis_tuser;
    wire                                rx_udp_hdr_valid;
    wire                                rx_udp_hdr_ready;
    wire [12:0]                         rx_udp_ip_fragment_offset;
    wire [31:0]                         rx_udp_ip_source_ip;
    wire [31:0]                         rx_udp_ip_dest_ip;
    wire [15:0]                         rx_udp_source_port;
    wire [15:0]                         rx_udp_dest_port;
    wire [15:0]                         rx_udp_length;
    wire [7:0]                          rx_udp_payload_axis_tdata;
    wire                                rx_udp_payload_axis_tvalid;
    wire                                rx_udp_payload_axis_tready;
    wire                                rx_udp_payload_axis_tlast;
    wire                                rx_udp_err;
    wire [31:0]                         local_ip;
    wire                                eth_mode;
    wire                                mdio_in;
    wire                                mdio_oen;
    wire                                mdio_out;

    //clk & reset
    wire                                clk;
    wire                                clk_2;
    wire                                ad_clk;
    wire                                da_clk;
    wire                                dsp_clk;
    wire                                rst;
    wire                                enet0_rst;
    wire                                tx_clk_mac;
    wire                                tx_clk_phy;

    //PLL
    wire                                pll_lock;
    wire                                pll_125m;
    wire                                pll_25m;
    wire                                eth_mode_tx_clk_mac_sync;

    //dac
    wire [DAC_CHANNEL-1:0]              dac_pcm_out_valid;
    wire [16*DAC_CHANNEL-1:0]           dac_pcm_out;
    wire [16*MIX_NUM*DAC_CHANNEL-1:0]   dac_cos_sita, dac_sin_sita;
    wire [4*MIX_NUM*DAC_CHANNEL-1:0]    dac_choose;
    wire [DAC_CHANNEL-1:0]              dac_err_clr;
    wire [DAC_CHANNEL-1:0]              dac_err;

    //mix freq
    wire [32*ADC_CHANNEL*FREQ_NUM-1:0]  mf_ipcm_acc_out;
    wire [32*ADC_CHANNEL*FREQ_NUM-1:0]  mf_qpcm_acc_out;
    wire [FREQ_NUM-1:0]                 mf_choose_lb;
    wire [4*FREQ_NUM-1:0]               mf_acc_shift;
    wire [24*FREQ_NUM-1:0]              mf_cycle_num;
    wire [FREQ_NUM-1:0]                 mf_err_clr;
    wire [FREQ_NUM-1:0]                 mf_err;
    wire                                mf_iq_read;

    //sincos_gen
    wire [16*FREQ_NUM-1:0]              sc_ipcm_out, sc_qpcm_out;
    wire                                sc_iqpcm_valid;
    wire                                sc_ad_valid;
    wire [4*FREQ_NUM-1:0]               sc_cic_rate;
    wire [16*FREQ_NUM-1:0]              sc_sin_length;
    wire                                sc_resync;
    wire [16*FREQ_NUM-1:0]              sc_status;
    wire                                sc_err;

    //pcm_udp
    wire                                pcm_udp_hdr_valid;
    wire                                pcm_udp_hdr_ready;
    wire [15:0]                         pcm_udp_length;
    wire [31:0]                         pcm_udp_remote_ip;
    wire [15:0]                         pcm_udp_remote_port;
    wire [15:0]                         pcm_udp_source_port;
    wire [7:0]                          pcm_udp_payload_axis_tdata;
    wire                                pcm_udp_payload_axis_tvalid;
    wire                                pcm_udp_payload_axis_tready;
    wire                                pcm_udp_payload_axis_tlast;
    wire                                pcm_udp_tx_start;
    wire [23:0]                         pcm_udp_tx_left;
    wire [23:0]                         pcm_udp_tx_total;
    wire [9:0]                          pcm_udp_tx_th;
    wire [7:0]                          pcm_udp_channel_choose;
    wire [7:0]                          pcm_udp_capture_sep;

    //sdio access
    wire                                sdio_miso;
    wire                                sdio_mosi;
    wire                                sdio_sck;

    //encoder
    wire                                encoder1_dir, encoder2_dir;
    wire                                encoder1_start, encoder2_start;
    wire                                encoder1_div, encoder2_div;
    wire [31:0]                         encoder1_cnt, encoder2_cnt;
    wire [31:0]                         encoder1_total_a, encoder1_total_b;
    wire [31:0]                         encoder2_total_a, encoder2_total_b;
    wire [11:0]                         encoder_pulse_width;
    wire                                encoder1_err, encoder2_err;
    wire [2:0]                          encoder1_err_status, encoder2_err_status;

    //iqbuf
    wire [15:0]                         iq_buf_write;
    wire [15:0]                         iq_buf_read;
    wire                                iq_buf_rst;
    wire                                iq_buf_block_ov;
    wire                                iq_buf_overflow;
    wire [31:0]                         sync_slot;
    wire [31:0]                         sync_encoder1, sync_encoder2;

    //shadow sc mem
    wire [16*MIX_NUM*DAC_CHANNEL-1:0]   shadow_cos_sita;
    wire [16*MIX_NUM*DAC_CHANNEL-1:0]   shadow_sin_sita;
    wire [4*MIX_NUM*DAC_CHANNEL-1:0]    shadow_choose;
    wire [15:0]                         shadow_read_addr;
    wire                                shadow_read_trigger;

    //controller
    wire                                trigger_exec;
    wire                                ctrl_out_udp_hdr_valid;
    wire                                ctrl_out_udp_hdr_ready;
    wire [31:0]                         ctrl_out_ip_dest_ip;
    wire [15:0]                         ctrl_out_udp_source_port;
    wire [15:0]                         ctrl_out_udp_dest_port;
    wire [15:0]                         ctrl_out_udp_length;
    wire [7:0]                          ctrl_out_udp_payload_axis_tdata;
    wire                                ctrl_out_udp_payload_axis_tvalid;
    wire                                ctrl_out_udp_payload_axis_tready;
    wire                                ctrl_out_udp_payload_axis_tlast;

    //AXI reg access
    wire [28:0]                         reg_addr;
    wire [31:0]                         reg_writedata;
    wire                                reg_rd_udp_mac;
    wire                                reg_wr_udp_mac;
    wire [31:0]                         reg_readdata_udp_mac;
    wire                                reg_busy_udp_mac;

    wire                                reg_rd_sc;
    wire                                reg_wr_sc;
    wire [31:0]                         reg_readdata_sc;
    wire                                reg_ready_sc;

    wire                                reg_rd_sdio;
    wire                                reg_wr_sdio;
    wire [31:0]                         reg_readdata_sdio;
    wire                                reg_ready_sdio;

    wire                                reg_wr_iq_buf;
    wire                                reg_rd_iq_buf;
    wire                                reg_ready_iq_buf;
    wire [31:0]                         reg_readdata_iq_buf;

    wire                                reg_rd_shadow_sc;
    wire                                reg_wr_shadow_sc;
    wire                                reg_ready_shadow_sc;
    wire [31:0]                         reg_readdata_shadow_sc;

    // ===== MDIO Tristate
    assign ENET0_CONFIG = 1'b0;
    assign mdio_in = ENET0_MDIO;
    assign ENET0_MDIO   = mdio_oen ? 1'bz : mdio_out;
    assign ENET0_RST_N = !enet0_rst;

enet_clk_pll enet_clk_pll_inst(
    .inclk0                             (CLOCK_50),
    .c0                                 (pll_125m),
    .c1                                 (pll_25m),
    .locked                             ()
);

main_pll main_pll_inst(
    .inclk0                             (CLOCK_50),
    .c0                                 (clk_2),
    .c1                                 (clk),
    .c2                                 (da_clk),
    .c3                                 (ad_clk),
`ifndef DEV_BOARD
    .c4                                 (DA_CLK_OUT),
`else
    .c4                                 (),
`endif
    .locked                             (pll_lock)
);

gen_reset #(.CTR_WIDTH(RESET_CTR_WIDTH)) gen_sys_reset(
    .clk                                (CLOCK_50),
    .reset_n_in                         (pll_lock & KEY[0]),
    .reset_out                          (rst)
);

gen_reset #(.CTR_WIDTH(ENET0_RST_CTR_WIDTH)) gen_enet_reset(
    .clk                                (CLOCK_50),
    .reset_n_in                         (pll_lock & KEY[0]),
    .reset_out                          (enet0_rst)
);

gen_key_signal #(.CTR_WIDTH(RESET_CTR_WIDTH)) gen_key1_signal(
    .clk                                (clk),
    .rst                                (rst),
    .key_in_n                           (KEY[1]),
    .key_out                            (trigger_exec)
);

`ifdef DEV_BOARD
glitch_remove glitch_remove_tx_pending(
    .clk                                (clk_2),
    .rst                                (rst),
    .glitch_in                          (tx_udp_payload_axis_tvalid & !tx_udp_payload_axis_tready),
    .glitch_free_out                    (TX_ERR)
);

glitch_remove glitch_remove_rx_pending(
    .clk                                (clk_2),
    .rst                                (rst),
    .glitch_in                          (rx_udp_payload_axis_tvalid & !rx_udp_payload_axis_tready),
    .glitch_free_out                    (RX_ERR)
);
`else
    assign DA_CLK_OUT1 = DA_CLK_OUT;
    assign AD_CLK_OUT = ad_clk;
    assign AD_MODE = 1;

generate
    genvar j;
    for (j=0; j<ADC_CHANNEL; j=j+1)
    begin : assign_da_pin
        always @(posedge da_clk)
            DA_PCM_OUT[14*j+13:14*j] <= #1 dac_pcm_out[16*j+15:16*j+2] + 14'h2000;
        assign DA_WR[j] = DA_CLK_OUT;
    end
endgenerate
generate
    genvar i;
    for (i=0; i<DACT_CHANNEL; i=i+1)
    begin : assign_dat_pin
        always @(posedge da_clk)
            DA_PCM_OUT_T[14*i+13:14*i] <= #1 dac_pcm_out[16*(i+ADC_CHANNEL)+15:16*(i+ADC_CHANNEL)+2] + 14'h2000;
        assign DA_WR_T[i] = DA_CLK_OUT;
    end
endgenerate
`endif

    wire [3:0]                          encoder_in;

    encoder encoder_1(
    .clk                                (clk_2),
    .rst                                (rst),
    .pulse_width                        (encoder_pulse_width),
    .Encoder_A                          (encoder_in[0]),
    .Encoder_B                          (encoder_in[1]),
    .Encoder_dir                        (encoder1_dir),
    .capture_start                      (encoder1_start),
    .Encoder_div_number                 (encoder1_div),
    .o_encoder_cnt_div_a                (encoder1_cnt),
    .encoder_total_a                    (encoder1_total_a),
    .encoder_total_b                    (encoder1_total_b),
    .o_encoder_err                      (encoder1_err),
    .err_status                         (encoder1_err_status)
    );

    encoder encoder_2(
    .clk                                (clk_2),
    .rst                                (rst),
    .pulse_width                        (encoder_pulse_width),
    .Encoder_A                          (encoder_in[2]),
    .Encoder_B                          (encoder_in[3]),
    .Encoder_dir                        (encoder2_dir),
    .capture_start                      (encoder2_start),
    .Encoder_div_number                 (encoder2_div),
    .o_encoder_cnt_div_a                (encoder2_cnt),
    .encoder_total_a                    (encoder2_total_a),
    .encoder_total_b                    (encoder2_total_b),
    .o_encoder_err                      (encoder2_err),
    .err_status                         (encoder2_err_status)
    );


`ifndef DEV_BOARD
    assign encoder_in[0] = ENCODER_IN[0];
    assign encoder_in[1] = ENCODER_IN[1];
    assign encoder_in[2] = ENCODER_IN[3];
    assign encoder_in[3] = ENCODER_IN[4];
    assign ENCODER_ERR[0] = encoder1_err;
    assign ENCODER_ERR[1] = encoder2_err;
`else
    reg [1:0]                           encoder_in_delay;
    assign encoder_in[0] = ENCODER_IN[0];
    assign encoder_in[1] = encoder_in_delay[0];
    assign encoder_in[2] = ENCODER_IN[1];
    assign encoder_in[3] = encoder_in_delay[1];
    always @(posedge clk_2)
        encoder_in_delay <= #1 ENCODER_IN;
`endif

synchronizer synchronizer_mac(
    .reset                              (rst),
    .clk                                (tx_clk_mac),
    .d                                  (eth_mode),
    .q                                  (eth_mode_tx_clk_mac_sync)
);

clkctrl1 clkctrl1_mac(
    .clkselect                          (eth_mode_tx_clk_mac_sync),
    .inclk0x                            (pll_25m),
    .inclk1x                            (pll_125m),
    .outclk                             (tx_clk_mac)
);


assign #2 ENET0_GTX_CLK = tx_clk_phy;

ddio_out1   ddio_out1_inst (
    .aclr                               ( rst ),
    .datain_h                           ( 1'b1 ),
    .datain_l                           ( 1'b0 ),
    .outclock                           ( tx_clk_mac ),
    .dataout                            ( tx_clk_phy )
    );


udp_mac_complete #(.REAL_PHY(REAL_PHY))
udp_mac_complete_inst (
    .clk                                (clk),
    .clk_2                              (clk_2),
    .rst                                (rst),

    //config register
    .reg_addr                           (reg_addr[7:0]),
    .reg_rd                             (reg_rd_udp_mac),
    .reg_wr                             (reg_wr_udp_mac),
    .reg_busy                           (reg_busy_udp_mac),
    .reg_writedata                      (reg_writedata),
    .reg_readdata                       (reg_readdata_udp_mac),

    //mii signal
    .tx_clk                             (tx_clk_mac),
    .rx_clk                             (ENET0_RX_CLK),
    .tx_control                         (ENET0_TX_EN),
    .rx_control                         (ENET0_RX_DV),
    .rgmii_in                           (ENET0_RX_DATA),
    .rgmii_out                          (ENET0_TX_DATA),

    //IP frame input
    .in_ip_hdr_valid                    (1'b0),
    .in_ip_hdr_ready                    (),
    .in_ip_dscp                         (),
    .in_ip_ecn                          (),
    .in_ip_length                       (),
    .in_ip_ttl                          (),
    .in_ip_protocol                     (),
    .in_ip_source_ip                    (),
    .in_ip_dest_ip                      (),
    .in_ip_payload_axis_tdata           (),
    .in_ip_payload_axis_tvalid          (1'b0),
    .in_ip_payload_axis_tready          (),
    .in_ip_payload_axis_tlast           (1'b0),
    .in_ip_payload_axis_tuser           (1'b0),

    // UDP frame input
    .tx_udp_hdr_valid                   (tx_udp_hdr_valid),
    .tx_udp_hdr_ready                   (tx_udp_hdr_ready),
    .tx_udp_ip_dscp                     (6'd0),
    .tx_udp_ip_ecn                      (2'd0),
    .tx_udp_ip_ttl                      (8'h80),
    .tx_udp_ip_dest_ip                  (tx_udp_ip_dest_ip),
    .tx_udp_source_port                 (tx_udp_source_port),
    .tx_udp_dest_port                   (tx_udp_dest_port),
    .tx_udp_length                      (tx_udp_length),
    .tx_udp_checksum                    (16'd0),
    .tx_udp_payload_axis_tdata          (tx_udp_payload_axis_tdata),
    .tx_udp_payload_axis_tvalid         (tx_udp_payload_axis_tvalid),
    .tx_udp_payload_axis_tready         (tx_udp_payload_axis_tready),
    .tx_udp_payload_axis_tlast          (tx_udp_payload_axis_tlast),
    .tx_udp_payload_axis_tuser          (1'b1),

    // UDP frame output
    .rx_udp_hdr_valid                   (rx_udp_hdr_valid),
    .rx_udp_hdr_ready                   (rx_udp_hdr_ready),
    .rx_udp_eth_dest_mac                (),
    .rx_udp_eth_src_mac                 (),
    .rx_udp_eth_type                    (),
    .rx_udp_ip_version                  (),
    .rx_udp_ip_ihl                      (),
    .rx_udp_ip_dscp                     (),
    .rx_udp_ip_ecn                      (),
    .rx_udp_ip_length                   (),
    .rx_udp_ip_identification           (),
    .rx_udp_ip_flags                    (),
    .rx_udp_ip_fragment_offset          (rx_udp_ip_fragment_offset),
    .rx_udp_ip_ttl                      (),
    .rx_udp_ip_protocol                 (),
    .rx_udp_ip_header_checksum          (),
    .rx_udp_ip_source_ip                (rx_udp_ip_source_ip),
    .rx_udp_ip_dest_ip                  (rx_udp_ip_dest_ip),
    .rx_udp_source_port                 (rx_udp_source_port),
    .rx_udp_dest_port                   (rx_udp_dest_port),
    .rx_udp_length                      (rx_udp_length),
    .rx_udp_checksum                    (),
    .rx_udp_payload_axis_tdata          (rx_udp_payload_axis_tdata),
    .rx_udp_payload_axis_tvalid         (rx_udp_payload_axis_tvalid),
    .rx_udp_payload_axis_tready         (rx_udp_payload_axis_tready),
    .rx_udp_payload_axis_tlast          (rx_udp_payload_axis_tlast),
    .rx_udp_payload_axis_tuser          (),
    .rx_udp_err                         (rx_udp_err),
    .local_ip                           (local_ip),
    .eth_mode                           (eth_mode),
    //mdio
    .mdc                                (ENET0_MDC),
    .mdio_in                            (mdio_in),
    .mdio_oen                           (mdio_oen),
    .mdio_out                           (mdio_out)
);

sincos_gen #(
    .FREQ_NUM                           (FREQ_NUM),
    .pcmaw                              (sintb_aw)
    ) sincos_gen_inst(
    //clock and reset
    .ad_clk                             (ad_clk),
    .da_clk                             (da_clk),
    .rst                                (rst),

    //pcm input and output
    .sc_iqpcm_valid                     (sc_iqpcm_valid),
    .sc_ipcm_out                        (sc_ipcm_out),
    .sc_qpcm_out                        (sc_qpcm_out),
    .sc_ad_valid                        (sc_ad_valid),

    //register access
    .clk_2                              (clk_2),
    .reg_addr                           (reg_addr[16:0]),
    .reg_rd                             (reg_rd_sc),
    .reg_wr                             (reg_wr_sc),
    .reg_ready                          (reg_ready_sc),
    .reg_writedata                      (reg_writedata),
    .reg_readdata                       (reg_readdata_sc),

    //controller
    .sc_sin_length                      (sc_sin_length),
    .sc_cic_rate                        (sc_cic_rate),
    .sc_resync                          (sc_resync),
    .sc_status                          (sc_status),
    .sc_err                             (sc_err)
);

mix_freq2_mc #(
    .FREQ_NUM                           (FREQ_NUM),
    .CHANNEL                            (ADC_CHANNEL)
    ) mix_freq2_mc_inst (
    //reset and clock
    .rst                                (rst),
    .clk1                               (clk),
    .clk_2                              (clk_2),
    .ad_clk                             (ad_clk),

    //pcm input
`ifndef DEV_BOARD
    .ad_pcm_in_valid                    ({ADC_CHANNEL{1'b1}}),
    .ad_pcm_in                          (AD_PCM_IN),
`else
    .ad_pcm_in_valid                    ({ADC_CHANNEL{1'b0}}),
    .ad_pcm_in                          (),
`endif
    .da_lb_pcm_in_valid                 (dac_pcm_out_valid[ADC_CHANNEL-1:0]),
    .da_lb_pcm_in                       (dac_pcm_out[16*ADC_CHANNEL-1:0]),

    //iq pcm input
    .ipcm_in                            (sc_ipcm_out),
    .qpcm_in                            (sc_qpcm_out),
    .iqpcm_valid						(sc_iqpcm_valid),
    .ad_valid                           (sc_ad_valid),
    .mf_ipcm_acc_out                    (mf_ipcm_acc_out),
    .mf_qpcm_acc_out                    (mf_qpcm_acc_out),

    //controller
    .mf_iq_read                         (mf_iq_read),
    .choose_lb                          (mf_choose_lb),
    .acc_shift                          (mf_acc_shift),
    .cycle_num                          (mf_cycle_num),
    .err_clr                            (mf_err_clr),
    .err                                (mf_err)
);

dac_tx2 #(
    .CHANNEL                            (DAC_CHANNEL),
    .FREQ_NUM                           (FREQ_NUM),
    .MIX_NUM                            (MIX_NUM)
    )  dac_tx2_inst(
    //reset and clock
    .rst                                (rst),
    .clk1                               (clk),
    .da_clk                             (da_clk),

    //iq pcm input
    .ipcm_in                            (sc_ipcm_out),
    .qpcm_in                            (sc_qpcm_out),
    .iqpcm_valid                        (sc_iqpcm_valid),

    //da pcm output
    .dac_pcm_out_valid                  (dac_pcm_out_valid),
    .dac_pcm_out                        (dac_pcm_out),

    //controller input
    .cos_sita                           (dac_cos_sita),
    .sin_sita                           (dac_sin_sita),
    .choose                             (dac_choose),
    .err_clr                            (dac_err_clr),
    .err                                (dac_err)
);

pcm2udp #(
`ifdef DEV_BOARD
    .CHANNEL                            (ADC_CHANNEL),
`else
    .CHANNEL                            (ADC_CHANNEL * 2),
`endif
    .pcmaw                              (pcm2usb_pcmaw)
) pcm2udp_inst(
    //clock and reset
    .pcm_in_clk                         (ad_clk),
    .clk                                (clk),
    .rst                                (rst),

    //pcm input and output
`ifdef DEV_BOARD
    .pcm_in_valid                       (dac_pcm_out_valid[ADC_CHANNEL-1:0]),
    .pcm_in                             (dac_pcm_out[16*ADC_CHANNEL-1:0]),
`else
    .pcm_in_valid                       ({{ADC_CHANNEL{1'b1}}, dac_pcm_out_valid[ADC_CHANNEL-1:0]}),
    .pcm_in                             ({AD_PCM_IN, dac_pcm_out[16*ADC_CHANNEL-1:0]}),
`endif
    //UDP frame output
    .pcm_udp_hdr_valid                  (pcm_udp_hdr_valid),
    .pcm_udp_hdr_ready                  (pcm_udp_hdr_ready),
    .pcm_udp_length                     (pcm_udp_length),
    .pcm_udp_payload_axis_tdata         (pcm_udp_payload_axis_tdata),
    .pcm_udp_payload_axis_tvalid        (pcm_udp_payload_axis_tvalid),
    .pcm_udp_payload_axis_tready        (pcm_udp_payload_axis_tready),
    .pcm_udp_payload_axis_tlast         (pcm_udp_payload_axis_tlast),

    //regiser access
    .pcm_udp_tx_left                    (pcm_udp_tx_left),
    .pcm_udp_tx_start                   (pcm_udp_tx_start),
    .pcm_udp_tx_total                   (pcm_udp_tx_total),
    .pcm_udp_tx_th                      (pcm_udp_tx_th),
    .pcm_udp_channel_choose             (pcm_udp_channel_choose),
    .pcm_udp_capture_sep                (pcm_udp_capture_sep)
);

iq_buf #(
    .FREQ_NUM                           (FREQ_NUM),
    .ADC_CHANNEL                        (ADC_CHANNEL)
) iq_buf_inst (
    .clk                                (clk_2),
    .rst                                (rst),

    //iq pcm input
    .mf_ipcm_acc_out                    (mf_ipcm_acc_out),
    .mf_qpcm_acc_out                    (mf_qpcm_acc_out),
    .sync_slot                          (sync_slot),
    .sync_encoder1                      (sync_encoder1),
    .sync_encoder2                      (sync_encoder2),

    //controller
    .mf_iq_read                         (mf_iq_read),
    .iq_buf_write                       (iq_buf_write),
    .iq_buf_read                        (iq_buf_read),
    .iq_buf_rst                         (iq_buf_rst),
    .iq_buf_block_ov                    (iq_buf_block_ov),
    .iq_buf_overflow                    (iq_buf_overflow),

    //AXI access
    .reg_addr                           (reg_addr[15:0]),
    .reg_readdata                       (reg_readdata_iq_buf),
    .reg_wr                             (reg_wr_iq_buf),
    .reg_rd                             (reg_rd_iq_buf),
    .reg_ready                          (reg_ready_iq_buf)
);

shadow_sc #(
    .MIX_NUM                            (MIX_NUM),
    .DAC_CHANNEL                        (DAC_CHANNEL)
) shadow_sc_inst(
    .clk                                (clk_2),
    .rst                                (rst),

    //controller interface
    .shadow_cos_sita                    (shadow_cos_sita),
    .shadow_sin_sita                    (shadow_sin_sita),
    .shadow_choose                      (shadow_choose),
    .shadow_read_addr                   (shadow_read_addr),
    .shadow_read_trigger                (shadow_read_trigger),

    //AXI interface
    .reg_addr                           (reg_addr[15:0]),
    .reg_readdata                       (reg_readdata_shadow_sc),
    .reg_writedata                      (reg_writedata),
    .reg_rd                             (reg_rd_shadow_sc),
    .reg_wr                             (reg_wr_shadow_sc),
    .reg_ready                          (reg_ready_shadow_sc)
);

sdio_master sdio_master_inst(
    .clk_2                              (clk_2),
    .rst                                (rst),
    //AXI reg access
    .reg_addr                           (reg_addr[7:0]),
    .reg_writedata                      (reg_writedata),
    .reg_rd_sdio                        (reg_rd_sdio),
    .reg_wr_sdio                        (reg_wr_sdio),
    .reg_ready_sdio                     (reg_ready_sdio),
    .reg_readdata_sdio                  (reg_readdata_sdio),

    //sdio access
    .sdio_miso                          (sdio_miso),
    .sdio_mosi                          (sdio_mosi),
    .sdio_sck                           (sdio_sck)
);

`ifdef DEV_BOARD
    wire [31:0]                         sdio_writedata, sdio_readdata;
    wire [7:0]                          sdio_addr;
    wire                                sdio_rd, sdio_wr;

sdio_slave sdio_slave_inst(
    //clock and reset
    .clk                                (clk_2),
    .rst                                (!rst),

    //reg access
    .sdio_addr                          (sdio_addr),
    .sdio_writedata                     (sdio_writedata),
    .sdio_rd                            (sdio_rd),
    .sdio_wr                            (sdio_wr),
    .sdio_readdata                      (sdio_readdata),

    //sdio access
    .sdio_miso                          (sdio_miso),
    .sdio_mosi                          (sdio_mosi),
    .sdio_sck                           (sdio_sck)
);

generic_spram #(
    .SIMULATION                         (SIMULATION),
    .aw                                 (8),
    .dw                                 (32)
) generic_spram_inst(
    .clk                                (clk_2),
    .re                                 (sdio_rd),
    .we                                 (sdio_wr),
    .addr                               (sdio_addr),
    .q                                  (sdio_readdata),
    .data                               (sdio_writedata)
);
`else
    assign SYN_SCK = sdio_sck;
    assign sdio_miso = SYN_SDATAIN;
    assign SYN_SDATAOUT = sdio_mosi;

    reg [2:0]                           counter;
    reg                                 syn_clk;

    always @(posedge clk)
    if (rst)
    begin
        counter <= #1 0;
        syn_clk <= #1 0;
    end
    else
    begin
        counter <= (counter==4) ? 0 : counter + 1;
        if (counter==4)
            syn_clk <= !syn_clk;
    end

    assign SYN_CLK = syn_clk;
`endif

controller #(
    .SIMULATION                         (SIMULATION),
    .DAC_CHANNEL                        (DAC_CHANNEL),
    .ADC_CHANNEL                        (ADC_CHANNEL),
    .FREQ_NUM                           (FREQ_NUM),
    .MIX_NUM                            (MIX_NUM)
) controller_inst(
    //input
    .clk                                (clk),
    .clk_2                              (clk_2),
    .rst                                (rst),
    .trigger_exec                       (trigger_exec),
    //UDP frame input
    .ctrl_in_udp_hdr_valid              (rx_udp_hdr_valid),
    .ctrl_in_udp_hdr_ready              (rx_udp_hdr_ready),
    .ctrl_in_ip_fragment_offset         (rx_udp_ip_fragment_offset),
    .ctrl_in_ip_source_ip               (rx_udp_ip_source_ip),
    .ctrl_in_ip_dest_ip                 (rx_udp_ip_dest_ip),
    .ctrl_in_udp_source_port            (rx_udp_source_port),
    .ctrl_in_udp_dest_port              (rx_udp_dest_port),
    .ctrl_in_udp_length                 (rx_udp_length),
    .ctrl_in_udp_payload_axis_tdata     (rx_udp_payload_axis_tdata),
    .ctrl_in_udp_payload_axis_tvalid    (rx_udp_payload_axis_tvalid),
    .ctrl_in_udp_payload_axis_tready    (rx_udp_payload_axis_tready),
    .ctrl_in_udp_payload_axis_tlast     (rx_udp_payload_axis_tlast),
    .ctrl_in_udp_err                    (rx_udp_err),

    //UDP frame output
    .ctrl_out_udp_hdr_valid             (ctrl_out_udp_hdr_valid),
    .ctrl_out_udp_hdr_ready             (ctrl_out_udp_hdr_ready),
    .ctrl_out_ip_dest_ip                (ctrl_out_ip_dest_ip),
    .ctrl_out_udp_source_port           (ctrl_out_udp_source_port),
    .ctrl_out_udp_dest_port             (ctrl_out_udp_dest_port),
    .ctrl_out_udp_length                (ctrl_out_udp_length),
    .ctrl_out_udp_payload_axis_tdata    (ctrl_out_udp_payload_axis_tdata),
    .ctrl_out_udp_payload_axis_tvalid   (ctrl_out_udp_payload_axis_tvalid),
    .ctrl_out_udp_payload_axis_tready   (ctrl_out_udp_payload_axis_tready),
    .ctrl_out_udp_payload_axis_tlast    (ctrl_out_udp_payload_axis_tlast),
    .local_ip                           (local_ip),

    //pcm2udp reg control
    .pcm_udp_tx_left                    (pcm_udp_tx_left),
    .pcm_udp_tx_start                   (pcm_udp_tx_start),
    .pcm_udp_tx_total                   (pcm_udp_tx_total),
    .pcm_udp_tx_th                      (pcm_udp_tx_th),
    .pcm_udp_channel_choose             (pcm_udp_channel_choose),
    .pcm_udp_capture_sep                (pcm_udp_capture_sep),
    .pcm_udp_remote_ip                  (pcm_udp_remote_ip),
    .pcm_udp_remote_port                (pcm_udp_remote_port),
    .pcm_udp_source_port                (pcm_udp_source_port),

    //dac reg control
    .dac_cos_sita                       (dac_cos_sita),
    .dac_sin_sita                       (dac_sin_sita),
    .dac_choose                         (dac_choose),
    .dac_err_clr                        (dac_err_clr),
    .dac_err                            (dac_err),

    //Gain control
`ifndef DEV_BOARD
    .ch_gain_sel                        (CH_GAIN_SEL),
    .ch_gain_da                         (CH_GAIN_DA),
    .ch_gain_wr                         (CH_GAIN_WR),
    .ch_gain_clr                        (CH_GAIN_CLR),
    .ch_gain_gain                       (CH_GAIN_GAIN),
    .ch_gain_buf                        (CH_GAIN_BUF),
    .ch_gain_ldac                       (CH_GAIN_LDAC),
    .model_sel                          (MODEL_SEL),
    .ch_emit_recv_en                    (CH_EMIT_RECV_EN),
    .ch_filter_sel                      (CH_FILTER_SEL),
    .syn_trigger_start                  (SYN_TRIG_START),
    .syn_trigger_pulse                  (SYN_TRIG_PULSE),

`else
    .ch_gain_sel                        (),
    .ch_gain_da                         (),
    .ch_gain_wr                         (),
    .ch_gain_clr                        (),
    .ch_gain_gain                       (),
    .ch_gain_buf                        (),
    .ch_gain_ldac                       (),
    .model_sel                          (),
    .ch_emit_recv_en                    (),
    .ch_filter_sel                      (),
    .syn_trigger_start                  (),
    .syn_trigger_pulse                  (),
`endif

    .slot_idx                           (slot_idx),
    //mix freq control
    .mf_ipcm_acc_out                    (mf_ipcm_acc_out),
    .mf_qpcm_acc_out                    (mf_qpcm_acc_out),
    .mf_iq_read                         (mf_iq_read),
    .mf_choose_lb                       (mf_choose_lb),
    .mf_acc_shift                       (mf_acc_shift),
    .mf_cycle_num                       (mf_cycle_num),
    .mf_err_clr                         (mf_err_clr),
    .mf_err                             (mf_err),

    //sincos gen control
    .sc_status                          (sc_status),
    .sc_sin_length                      (sc_sin_length),
    .sc_resync                          (sc_resync),
    .sc_err                             (sc_err),
    .sc_cic_rate                        (sc_cic_rate),

    //iq buffer
    .sync_slot                          (sync_slot),
    .sync_encoder1                      (sync_encoder1),
    .sync_encoder2                      (sync_encoder2),
    .iq_buf_write                       (iq_buf_write),
    .iq_buf_rst                         (iq_buf_rst),
    .iq_buf_block_ov                    (iq_buf_block_ov),
    .iq_buf_overflow                    (iq_buf_overflow),

    //controller interface
    .shadow_cos_sita                    (shadow_cos_sita),
    .shadow_sin_sita                    (shadow_sin_sita),
    .shadow_choose                      (shadow_choose),
    .shadow_read_addr                   (shadow_read_addr),
    .shadow_read_trigger                (shadow_read_trigger),

    //encoder control
    .encoder1_dir                       (encoder1_dir),
    .encoder1_start                     (encoder1_start),
    .encoder1_div                       (encoder1_div),
    .encoder1_cnt                       (encoder1_cnt),
    .encoder1_total_a                   (encoder1_total_a),
    .encoder1_total_b                   (encoder1_total_b),
    .encoder2_dir                       (encoder2_dir),
    .encoder2_start                     (encoder2_start),
    .encoder2_div                       (encoder2_div),
    .encoder2_cnt                       (encoder2_cnt),
    .encoder2_total_a                   (encoder2_total_a),
    .encoder2_total_b                   (encoder2_total_b),
    .encoder_pulse_width                (encoder_pulse_width),
    .encoder1_err_status                (encoder1_err_status),
    .encoder2_err_status                (encoder2_err_status),

    //AXI reg access
    .reg_addr                           (reg_addr),
    .reg_writedata                      (reg_writedata),
    .reg_rd_udp_mac                     (reg_rd_udp_mac),
    .reg_wr_udp_mac                     (reg_wr_udp_mac),
    .reg_ready_udp_mac                  (!reg_busy_udp_mac),
    .reg_readdata_udp_mac               (reg_readdata_udp_mac),

    .reg_rd_sc                          (reg_rd_sc),
    .reg_wr_sc                          (reg_wr_sc),
    .reg_ready_sc                       (reg_ready_sc),
    .reg_readdata_sc                    (reg_readdata_sc),

    .reg_rd_sdio                        (reg_rd_sdio),
    .reg_wr_sdio                        (reg_wr_sdio),
    .reg_ready_sdio                     (reg_ready_sdio),
    .reg_readdata_sdio                  (reg_readdata_sdio),

    .reg_wr_iq_buf                      (reg_wr_iq_buf),
    .reg_rd_iq_buf                      (reg_rd_iq_buf),
    .reg_ready_iq_buf                   (reg_ready_iq_buf),
    .reg_readdata_iq_buf                (reg_readdata_iq_buf),

    .reg_rd_shadow_sc                   (reg_rd_shadow_sc),
    .reg_wr_shadow_sc                   (reg_wr_shadow_sc),
    .reg_ready_shadow_sc                (reg_ready_shadow_sc),
    .reg_readdata_shadow_sc             (reg_readdata_shadow_sc)
);

udp_arb_mux #(
    .S_COUNT                            (2),
    .ARB_TYPE                           ("ROUND_ROBIN"),
    .USER_ENABLE                        (0)
) udp_arb_mux_inst(
    .clk                                (clk),
    .rst                                (rst),
    .s_udp_hdr_valid                    ({ctrl_out_udp_hdr_valid, pcm_udp_hdr_valid}),
    .s_udp_hdr_ready                    ({ctrl_out_udp_hdr_ready, pcm_udp_hdr_ready}),
    .s_eth_dest_mac                     (),
    .s_eth_src_mac                      (),
    .s_eth_type                         (),
    .s_ip_version                       (),
    .s_ip_ihl                           (),
    .s_ip_dscp                          (),
    .s_ip_ecn                           (),
    .s_ip_length                        (),
    .s_ip_identification                (),
    .s_ip_flags                         (),
    .s_ip_fragment_offset               (),
    .s_ip_ttl                           (),
    .s_ip_protocol                      (),
    .s_ip_header_checksum               (),
    .s_ip_source_ip                     (),
    .s_ip_dest_ip                       ({ctrl_out_ip_dest_ip, pcm_udp_remote_ip}),
    .s_udp_source_port                  ({ctrl_out_udp_source_port, pcm_udp_source_port}),
    .s_udp_dest_port                    ({ctrl_out_udp_dest_port, pcm_udp_remote_port}),
    .s_udp_length                       ({ctrl_out_udp_length, pcm_udp_length}),
    .s_udp_checksum                     (),
    .s_udp_payload_axis_tkeep           (),
    .s_udp_payload_axis_tid             (),
    .s_udp_payload_axis_tdest           (),
    .s_udp_payload_axis_tuser           (),
    .s_udp_payload_axis_tdata           ({ctrl_out_udp_payload_axis_tdata, pcm_udp_payload_axis_tdata}),
    .s_udp_payload_axis_tvalid          ({ctrl_out_udp_payload_axis_tvalid, pcm_udp_payload_axis_tvalid}),
    .s_udp_payload_axis_tready          ({ctrl_out_udp_payload_axis_tready, pcm_udp_payload_axis_tready}),
    .s_udp_payload_axis_tlast           ({ctrl_out_udp_payload_axis_tlast, pcm_udp_payload_axis_tlast}),
    .m_udp_hdr_valid                    (tx_udp_hdr_valid),
    .m_udp_hdr_ready                    (tx_udp_hdr_ready),
    .m_eth_dest_mac                     (),
    .m_eth_src_mac                      (),
    .m_eth_type                         (),
    .m_ip_version                       (),
    .m_ip_ihl                           (),
    .m_ip_dscp                          (),
    .m_ip_ecn                           (),
    .m_ip_length                        (),
    .m_ip_identification                (),
    .m_ip_flags                         (),
    .m_ip_fragment_offset               (),
    .m_ip_ttl                           (),
    .m_ip_protocol                      (),
    .m_ip_header_checksum               (),
    .m_ip_source_ip                     (),
    .m_ip_dest_ip                       (tx_udp_ip_dest_ip),
    .m_udp_source_port                  (tx_udp_source_port),
    .m_udp_dest_port                    (tx_udp_dest_port),
    .m_udp_length                       (tx_udp_length),
    .m_udp_checksum                     (),
    .m_udp_payload_axis_tkeep           (),
    .m_udp_payload_axis_tid             (),
    .m_udp_payload_axis_tdest           (),
    .m_udp_payload_axis_tuser           (),
    .m_udp_payload_axis_tdata           (tx_udp_payload_axis_tdata),
    .m_udp_payload_axis_tvalid          (tx_udp_payload_axis_tvalid),
    .m_udp_payload_axis_tready          (tx_udp_payload_axis_tready),
    .m_udp_payload_axis_tlast           (tx_udp_payload_axis_tlast)
);
endmodule