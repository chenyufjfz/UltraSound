library verilog;
use verilog.vl_types.all;
entity shadow_sc is
    generic(
        MIX_NUM         : integer := 5;
        DAC_CHANNEL     : integer := 10
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        shadow_cos_sita : out    vl_logic_vector;
        shadow_sin_sita : out    vl_logic_vector;
        shadow_choose   : out    vl_logic_vector;
        shadow_read_addr: in     vl_logic_vector(15 downto 0);
        shadow_read_trigger: in     vl_logic;
        reg_readdata    : out    vl_logic_vector(31 downto 0);
        reg_writedata   : in     vl_logic_vector(31 downto 0);
        reg_rd          : in     vl_logic;
        reg_wr          : in     vl_logic;
        reg_ready       : out    vl_logic;
        reg_addr        : in     vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MIX_NUM : constant is 1;
    attribute mti_svvh_generic_type of DAC_CHANNEL : constant is 1;
end shadow_sc;
