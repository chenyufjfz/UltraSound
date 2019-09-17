library verilog;
use verilog.vl_types.all;
entity fir_lane is
    generic(
        gen_param_addr  : integer := 1;
        acw             : integer := 31;
        pcmaw           : integer := 9;
        mul_num         : integer := 2
    );
    port(
        rst             : in     vl_logic;
        clk1            : in     vl_logic;
        pcm_clk         : in     vl_logic;
        pcm_in_wr       : in     vl_logic;
        pcm_in          : in     vl_logic_vector(15 downto 0);
        pcm_in_address  : in     vl_logic_vector;
        pcm_out         : out    vl_logic_vector(15 downto 0);
        param_q         : in     vl_logic_vector;
        param_addr      : out    vl_logic_vector;
        pcm_out_shift   : in     vl_logic_vector(3 downto 0);
        fir_start       : in     vl_logic;
        tap_len         : in     vl_logic_vector(11 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of gen_param_addr : constant is 1;
    attribute mti_svvh_generic_type of acw : constant is 1;
    attribute mti_svvh_generic_type of pcmaw : constant is 1;
    attribute mti_svvh_generic_type of mul_num : constant is 1;
end fir_lane;
