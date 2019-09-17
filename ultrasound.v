`timescale 1ns / 1ps

//`define DEV_BOARD

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


`ifndef    DEV_BOARD
    //AD interface
    AD_CLK_OUT,
    AD_PCM_IN,
    AD_MODE,

    //DA interface
    DA_CLK_OUT,
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
    CH_SEL_419,
`else
    //status led
    TX_ERR,
    RX_ERR
`endif    
);
parameter SIMULATION = 0;
parameter RESET_CTR_WIDTH = SIMULATION ? 5 : 22;
parameter ENET0_RST_CTR_WIDTH = 21;
parameter DAC_CHANNEL = 4;
parameter ADC_CHANNEL = 2;
parameter FREQ_NUM = 4;
parameter pcm2usb_pcmaw = 11;
parameter dac_pcmaw = 12;
parameter sintb_aw = 12;
parameter DA_AD_RATE = 8'd2;
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
    output                              CH_SEL_419;
`else                                   
    //status led                        
    output                              TX_ERR;
    output                              RX_ERR;
`endif

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
    wire [DAC_CHANNEL-1:0]              dac_pcm_out_ready;
    wire [16*DAC_CHANNEL-1:0]           dac_pcm_out;
    wire [DAC_CHANNEL*dac_pcmaw-1:0]    dac_signal_len;
    wire [DAC_CHANNEL*4-1:0]            dac_cic_rate;
    wire                                dac_run;
    wire                                dac_resync;
                                        
    //adc                               
    wire [16*ADC_CHANNEL-1:0]           lb_dac_pcm;
    wire [ADC_CHANNEL-1:0]              lb_dac_pcm_valid;
    wire [ADC_CHANNEL-1:0]              lb_dac_pcm_ready;

    //mix freq
    wire [32*ADC_CHANNEL*FREQ_NUM-1:0]  mf_ipcm_acc_out;
    wire [32*ADC_CHANNEL*FREQ_NUM-1:0]  mf_qpcm_acc_out;
    wire [4*FREQ_NUM-1:0]               mf_pcm_out_shift;
    wire [FREQ_NUM-1:0]                 mf_choose_lb;
    wire [8*FREQ_NUM-1:0]               mf_dec_rate;
    wire [8*FREQ_NUM-1:0]               mf_dec_rate2;
    wire [4*FREQ_NUM-1:0]               mf_acc_shift;
    wire [16*FREQ_NUM-1:0]              mf_sin_length;
    wire [24*FREQ_NUM-1:0]              mf_cycle_num;
    wire [32*FREQ_NUM-1:0]              mf_status;
    wire [FREQ_NUM-1:0]                 mf_ctrl_resync;
    wire [FREQ_NUM-1:0]                 mf_reg_ready;
    wire [31:0]                         mf_reg_readdata[FREQ_NUM-1:0];
                                        
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
    wire                                reg_rd_pcm_udp;
    wire                                reg_wr_pcm_udp;
    wire                                reg_rd_dac;
    wire                                reg_wr_dac;
    wire                                reg_rd_mf;
    wire                                reg_wr_mf;
    wire                                reg_busy_udp_mac;    
    wire [31:0]                         reg_readdata_udp_mac;
    wire [31:0]                         reg_readdata_dac;
    wire [31:0]                         reg_readdata_mf;
    wire                                reg_ready_dac;
    wire                                reg_ready_mf;
    
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

dac_tx #(
    .CHANNEL                            (DAC_CHANNEL),
    .pcmaw                              (dac_pcmaw)
) dac_tx_inst(
    //clock and reset
    .pcm_clk                            (da_clk),
    .rst                                (rst),

    //pcm input and output
    .dac_pcm_out_valid                  (dac_pcm_out_valid),
    .dac_pcm_out_ready                  (dac_pcm_out_ready),
    .dac_pcm_out                        (dac_pcm_out),

    //register access
    .clk_2                              (clk_2),
    .reg_addr                           (reg_addr[15:0]),
    .reg_rd                             (reg_rd_dac),
    .reg_wr                             (reg_wr_dac),
    .reg_ready                          (reg_ready_dac),
    .reg_writedata                      (reg_writedata),
    .reg_readdata                       (reg_readdata_dac),

    .dac_signal_len                     (dac_signal_len),
    .dac_cic_rate                       (dac_cic_rate),
    .dac_run                            (dac_run),
    .ad_clk                             (ad_clk),
    .dac_resync                         (dac_resync)
);
assign dac_pcm_out_ready = {DAC_CHANNEL{1'b1}};

generate
genvar k;
for (k=0; k<ADC_CHANNEL; k=k+1)
begin : da_loopback
pcmmux_fifo #(
    .CHANNEL                            (1'b1),
    .pcmaw                              (1'b1)
) ad_da_mux(
//clock and reset
    .pcm_in_clk                         (da_clk),
    .pcm_out_clk                        (ad_clk),
    .rst                                (rst | dac_resync),

    //pcm input and output
    .pcm_in_valid                       (dac_pcm_out_valid[k]),
    .pcm_in_ready                       (),
    .pcm_in                             (dac_pcm_out[16*k+15:16*k]),
    .pcm_out_valid                      (lb_dac_pcm_valid[k]),
    .pcm_out_ready                      (lb_dac_pcm_ready[k]),
    .pcm_out                            (lb_dac_pcm[16*k+15:16*k]),

    //register access
    .pcm_channel_choose                 (8'd0),
    .pcm_available                      (),
    .pcm_capture_sep                    (DA_AD_RATE - 1'b1)
);
end
endgenerate

assign lb_dac_pcm_ready = {ADC_CHANNEL{1'b1}};

generate
genvar m;
for (m=0; m<FREQ_NUM; m=m+1)
begin : mix_inst
mix_freq_mc #(
    .CHANNEL                            (ADC_CHANNEL),
    .pcmaw                              (sintb_aw)
) mix_freq_mc_inst(
    //reset and clock
    .rst                                (rst),
    .clk1                               (clk),
    .pcm_clk                            (ad_clk),

    //pcm input
    .ad_pcm_in_valid                    ({ADC_CHANNEL{1'b1}}),
    .ad_pcm_in_ready                    (),
`ifndef DEV_BOARD    
    .ad_pcm_in                          (AD_PCM_IN),
`else
    .ad_pcm_in                          (),
`endif
    .da_lb_pcm_in_valid                 (lb_dac_pcm_valid),
    .da_lb_pcm_in_ready                 (),
    .da_lb_pcm_in                       (lb_dac_pcm),

    //iq pcm output
    .ipcm_dec_out_valid                 (),
    .ipcm_dec_out_ready                 ({ADC_CHANNEL{1'b1}}),
    .ipcm_dec_out                       (),
    .ipcm_acc_out                       (mf_ipcm_acc_out[32*ADC_CHANNEL*(m+1)-1 : 32*ADC_CHANNEL*m]),
    .qpcm_dec_out_valid                 (),
    .qpcm_dec_out_ready                 ({ADC_CHANNEL{1'b1}}),
    .qpcm_dec_out                       (),
    .qpcm_acc_out                       (mf_qpcm_acc_out[32*ADC_CHANNEL*(m+1)-1 : 32*ADC_CHANNEL*m]),
    .iqpcm_dump_valid                   (),
    .iqpcm_dump                         (),

    //register access
    .clk_2                              (clk_2),
    .reg_addr                           (reg_addr[12:0]),
    .reg_rd                             (reg_rd_mf & reg_addr[15:13] == m),
    .reg_wr                             (reg_wr_mf & reg_addr[15:13] == m),
    .reg_ready                          (mf_reg_ready[m]),
    .reg_writedata                      (reg_writedata),
    .reg_readdata                       (mf_reg_readdata[m]),

    //controller input
    .pcm_out_shift                      (mf_pcm_out_shift[4*m+3:4*m]),
    .choose_lb                          (mf_choose_lb[m]),
    .dec_rate                           (mf_dec_rate[8*m+7:8*m]),
    .dec_rate2                          (mf_dec_rate2[8*m+7:8*m]),
    .acc_shift                          (mf_acc_shift[4*m+3:4*m]),
    .sin_length                         (mf_sin_length[16*m+sintb_aw-1:16*m]),
    .cycle_num                          (mf_cycle_num[24*m+23:24*m]),
    .status                             (mf_status[32*m+31:32*m]),
    .resync                             (mf_ctrl_resync[m] | dac_resync)
);
end
endgenerate
    assign reg_ready_mf = (reg_addr[15:13] < FREQ_NUM) ? mf_reg_ready[reg_addr[15:13]] : 1'b1;
    assign reg_readdata_mf = (reg_addr[15:13] < FREQ_NUM) ? mf_reg_readdata[reg_addr[15:13]] : 32'h0BAD0BAD;

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
    .pcm_in_valid                       ({lb_dac_pcm_valid & lb_dac_pcm_ready}),
    .pcm_in                             ({lb_dac_pcm}),
`else
    .pcm_in_valid                       ({{ADC_CHANNEL{1'b1}}, lb_dac_pcm_valid & lb_dac_pcm_ready}),
    .pcm_in                             ({AD_PCM_IN, lb_dac_pcm}),
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

controller #(
    .SIMULATION                         (SIMULATION),
    .DAC_CHANNEL                        (DAC_CHANNEL),
    .ADC_CHANNEL                        (ADC_CHANNEL),
    .FREQ_NUM                           (FREQ_NUM),
    .dac_pcmaw                          (dac_pcmaw)
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
    .dac_signal_len                     (dac_signal_len),
    .dac_cic_rate                       (dac_cic_rate),
    .dac_run                            (dac_run),

    //Gain control
`ifndef DEV_BOARD
    .ch_gain_sel                        (CH_GAIN_SEL), 
    .ch_gain_da                         (CH_GAIN_DA),
    .ch_gain_wr                         (CH_GAIN_WR),
    .ch_gain_clr                        (CH_GAIN_CLR),
    .ch_gain_gain                       (CH_GAIN_GAIN),
    .ch_gain_buf                        (CH_GAIN_BUF),
    .ch_gain_ldac                       (CH_GAIN_LDAC),
    .ch_sel_419                         (CH_SEL_419),
`else
    .ch_gain_sel                        (), 
    .ch_gain_da                         (),
    .ch_gain_wr                         (),
    .ch_gain_clr                        (),
    .ch_gain_gain                       (),
    .ch_gain_buf                        (),
    .ch_gain_ldac                       (),
    .ch_sel_419                         (),    
`endif

    //mix freq control
    .mf_ipcm_acc_out                    (mf_ipcm_acc_out),
    .mf_qpcm_acc_out                    (mf_qpcm_acc_out),
    .mf_pcm_out_shift                   (mf_pcm_out_shift),
    .mf_choose_lb                       (mf_choose_lb),
    .mf_dec_rate                        (mf_dec_rate),
    .mf_dec_rate2                       (mf_dec_rate2),
    .mf_acc_shift                       (mf_acc_shift),
    .mf_sin_length                      (mf_sin_length),
    .mf_cycle_num                       (mf_cycle_num),
    .mf_status                          (mf_status),
    .mf_ctrl_resync                     (mf_ctrl_resync),
    
    //AXI reg access
    .reg_addr                           (reg_addr),
    .reg_writedata                      (reg_writedata),
    .reg_rd_udp_mac                     (reg_rd_udp_mac),
    .reg_wr_udp_mac                     (reg_wr_udp_mac),
    .reg_rd_dac                         (reg_rd_dac),
    .reg_wr_dac                         (reg_wr_dac),
    .reg_rd_mf                          (reg_rd_mf),
    .reg_wr_mf                          (reg_wr_mf),
    .reg_ready_udp_mac                  (!reg_busy_udp_mac),
    .reg_ready_dac                      (reg_ready_dac),
    .reg_ready_mf                       (reg_ready_mf),
    .reg_readdata_udp_mac               (reg_readdata_udp_mac),
    .reg_readdata_dac                   (reg_readdata_dac),
    .reg_readdata_mf                    (reg_readdata_mf) 
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