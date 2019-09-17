library verilog;
use verilog.vl_types.all;
entity fir_mc is
    generic(
        CHANNEL         : integer := 8;
        FIR_LANE        : integer := 4;
        acw             : integer := 31;
        pcmaw           : integer := 9;
        mul_num         : integer := 2;
        PARAM_SHADOW_RAM: integer := 1
    );
    port(
        pcm_clk         : in     vl_logic;
        clk1            : in     vl_logic;
        rst             : in     vl_logic;
        pcm_in_valid    : in     vl_logic_vector;
        pcm_in_ready    : out    vl_logic_vector;
        pcm_in          : in     vl_logic_vector;
        pcm_out_valid   : out    vl_logic_vector;
        pcm_out_ready   : in     vl_logic_vector;
        pcm_out         : out    vl_logic_vector;
        clk_2           : in     vl_logic;
        reg_addr        : in     vl_logic_vector(11 downto 0);
        reg_rd          : in     vl_logic;
        reg_wr          : in     vl_logic;
        reg_ready       : out    vl_logic;
        reg_writedata   : in     vl_logic_vector(31 downto 0);
        reg_readdata    : out    vl_logic_vector(31 downto 0);
        pcm_out_shift   : in     vl_logic_vector(3 downto 0);
        bypass          : in     vl_logic;
        down_sample     : in     vl_logic_vector(11 downto 0);
        tap_len         : in     vl_logic_vector(11 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CHANNEL : constant is 1;
    attribute mti_svvh_generic_type of FIR_LANE : constant is 1;
    attribute mti_svvh_generic_type of acw : constant is 1;
    attribute mti_svvh_generic_type of pcmaw : constant is 1;
    attribute mti_svvh_generic_type of mul_num : constant is 1;
    attribute mti_svvh_generic_type of PARAM_SHADOW_RAM : constant is 1;
end fir_mc;
