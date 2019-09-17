library verilog;
use verilog.vl_types.all;
entity reg_dec_rate is
    generic(
        AW              : integer := 10
    );
    port(
        clk             : in     vl_logic;
        clk_2           : in     vl_logic;
        rst             : in     vl_logic;
        reg_s_addr      : in     vl_logic_vector;
        reg_s_rd        : in     vl_logic;
        reg_s_wr        : in     vl_logic;
        reg_s_ready     : out    vl_logic;
        reg_s_writedata : in     vl_logic_vector(31 downto 0);
        reg_s_readdata  : out    vl_logic_vector(31 downto 0);
        reg_m_addr      : out    vl_logic_vector;
        reg_m_rd        : out    vl_logic;
        reg_m_wr        : out    vl_logic;
        reg_m_ready     : in     vl_logic;
        reg_m_writedata : out    vl_logic_vector(31 downto 0);
        reg_m_readdata  : in     vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of AW : constant is 1;
end reg_dec_rate;
