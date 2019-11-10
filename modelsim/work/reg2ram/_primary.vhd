library verilog;
use verilog.vl_types.all;
entity reg2ram is
    generic(
        REG_NUM         : integer := 10;
        BUF_NUM         : integer := 80
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        seq_reg         : in     vl_logic_vector;
        write_addr      : out    vl_logic_vector;
        write_trigger   : in     vl_logic;
        write_rst       : in     vl_logic;
        reg_readdata    : out    vl_logic_vector(31 downto 0);
        reg_rd          : in     vl_logic;
        reg_ready       : out    vl_logic;
        reg_addr        : in     vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of REG_NUM : constant is 1;
    attribute mti_svvh_generic_type of BUF_NUM : constant is 1;
end reg2ram;
