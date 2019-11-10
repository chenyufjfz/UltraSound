library verilog;
use verilog.vl_types.all;
entity sincos_gen is
    generic(
        pcmaw           : integer := 11;
        FREQ_NUM        : integer := 5;
        AD_RATIO        : integer := 2
    );
    port(
        da_clk          : in     vl_logic;
        ad_clk          : in     vl_logic;
        rst             : in     vl_logic;
        sc_iqpcm_valid  : out    vl_logic;
        sc_ipcm_out     : out    vl_logic_vector;
        sc_qpcm_out     : out    vl_logic_vector;
        sc_ad_valid     : out    vl_logic;
        clk_2           : in     vl_logic;
        reg_addr        : in     vl_logic_vector(16 downto 0);
        reg_rd          : in     vl_logic;
        reg_wr          : in     vl_logic;
        reg_ready       : out    vl_logic;
        reg_writedata   : in     vl_logic_vector(31 downto 0);
        reg_readdata    : out    vl_logic_vector(31 downto 0);
        sc_sin_length   : in     vl_logic_vector;
        sc_cic_rate     : in     vl_logic_vector;
        sc_resync       : in     vl_logic;
        sc_status       : out    vl_logic_vector;
        sc_err          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of pcmaw : constant is 1;
    attribute mti_svvh_generic_type of FREQ_NUM : constant is 1;
    attribute mti_svvh_generic_type of AD_RATIO : constant is 1;
end sincos_gen;
