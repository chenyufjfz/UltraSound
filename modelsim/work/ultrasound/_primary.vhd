library verilog;
use verilog.vl_types.all;
entity ultrasound is
    generic(
        SIMULATION      : integer := 0;
        RESET_CTR_WIDTH : vl_notype;
        ENET0_RST_CTR_WIDTH: integer := 21;
        DAC_CHANNEL     : integer := 4;
        ADC_CHANNEL     : integer := 2;
        FREQ_NUM        : integer := 4;
        pcm2usb_pcmaw   : integer := 11;
        dac_pcmaw       : integer := 12;
        sintb_aw        : integer := 12;
        DA_AD_RATE      : vl_logic_vector(0 to 7) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0);
        REAL_PHY        : integer := 4369
    );
    port(
        CLOCK_50        : in     vl_logic;
        KEY             : in     vl_logic_vector(1 downto 0);
        ENET0_GTX_CLK   : out    vl_logic;
        ENET0_MDC       : out    vl_logic;
        ENET0_MDIO      : inout  vl_logic;
        ENET0_RST_N     : out    vl_logic;
        ENET0_RX_CLK    : in     vl_logic;
        ENET0_RX_DATA   : in     vl_logic_vector(3 downto 0);
        ENET0_RX_DV     : in     vl_logic;
        ENET0_TX_DATA   : out    vl_logic_vector(3 downto 0);
        ENET0_TX_EN     : out    vl_logic;
        ENET0_CONFIG    : out    vl_logic;
        TX_ERR          : out    vl_logic;
        RX_ERR          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SIMULATION : constant is 1;
    attribute mti_svvh_generic_type of RESET_CTR_WIDTH : constant is 3;
    attribute mti_svvh_generic_type of ENET0_RST_CTR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DAC_CHANNEL : constant is 1;
    attribute mti_svvh_generic_type of ADC_CHANNEL : constant is 1;
    attribute mti_svvh_generic_type of FREQ_NUM : constant is 1;
    attribute mti_svvh_generic_type of pcm2usb_pcmaw : constant is 1;
    attribute mti_svvh_generic_type of dac_pcmaw : constant is 1;
    attribute mti_svvh_generic_type of sintb_aw : constant is 1;
    attribute mti_svvh_generic_type of DA_AD_RATE : constant is 1;
    attribute mti_svvh_generic_type of REAL_PHY : constant is 1;
end ultrasound;
