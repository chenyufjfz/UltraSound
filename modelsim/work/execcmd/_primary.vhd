library verilog;
use verilog.vl_types.all;
entity execcmd is
    generic(
        AW              : integer := 10
    );
    port(
        clk             : in     vl_logic;
        clk_2           : in     vl_logic;
        rst             : in     vl_logic;
        inram_address   : out    vl_logic_vector;
        inram_re        : out    vl_logic;
        inram_q         : in     vl_logic_vector(15 downto 0);
        outram_address  : out    vl_logic_vector;
        outram_we       : out    vl_logic;
        outram_d        : out    vl_logic_vector(15 downto 0);
        reg_addr_c2     : out    vl_logic_vector(13 downto 0);
        reg_rd_c2       : out    vl_logic;
        reg_wr_c2       : out    vl_logic;
        reg_ready_c2    : in     vl_logic;
        reg_writedata_c2: out    vl_logic_vector(31 downto 0);
        reg_readdata_c2 : in     vl_logic_vector(31 downto 0);
        start_exec      : in     vl_logic;
        busy            : out    vl_logic;
        err             : out    vl_logic;
        out_len         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of AW : constant is 1;
end execcmd;
