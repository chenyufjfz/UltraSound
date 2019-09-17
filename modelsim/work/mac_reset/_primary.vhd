library verilog;
use verilog.vl_types.all;
entity mac_reset is
    generic(
        REAL_PHY        : integer := 0
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        set_1000        : in     vl_logic;
        rst_writedata   : out    vl_logic_vector(31 downto 0);
        rst_readdata    : in     vl_logic_vector(31 downto 0);
        rst_addr        : out    vl_logic_vector(7 downto 0);
        rst_rd          : out    vl_logic;
        rst_wr          : out    vl_logic;
        reg_busy        : in     vl_logic;
        rst_finish      : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of REAL_PHY : constant is 1;
end mac_reset;
