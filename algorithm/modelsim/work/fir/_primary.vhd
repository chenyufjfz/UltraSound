library verilog;
use verilog.vl_types.all;
entity fir is
    generic(
        FIR_LANE        : integer := 4;
        gen_param_addr  : integer := 1;
        acw             : integer := 31;
        pcmaw           : integer := 9;
        mul_num         : integer := 2
    );
    port(
        pcm_clk         : in     vl_logic;
        clk1            : in     vl_logic;
        rst             : in     vl_logic;
        pcm_in_valid    : in     vl_logic;
        pcm_in_ready    : out    vl_logic;
        pcm_in          : in     vl_logic_vector(15 downto 0);
        pcm_out_valid   : out    vl_logic;
        pcm_out_ready   : in     vl_logic;
        pcm_out         : out    vl_logic_vector(15 downto 0);
        param_q         : in     vl_logic_vector;
        param_addr      : out    vl_logic_vector;
        pcm_out_shift   : in     vl_logic_vector(3 downto 0);
        bypass          : in     vl_logic;
        down_sample     : in     vl_logic_vector(11 downto 0);
        tap_len         : in     vl_logic_vector(11 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FIR_LANE : constant is 1;
    attribute mti_svvh_generic_type of gen_param_addr : constant is 1;
    attribute mti_svvh_generic_type of acw : constant is 1;
    attribute mti_svvh_generic_type of pcmaw : constant is 1;
    attribute mti_svvh_generic_type of mul_num : constant is 1;
end fir;
