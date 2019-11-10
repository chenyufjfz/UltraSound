library verilog;
use verilog.vl_types.all;
entity sincos_mem is
    generic(
        pcmaw           : integer := 10;
        UNIT1           : vl_logic_vector(0 to 15) := (Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        da_clk          : in     vl_logic;
        rst             : in     vl_logic;
        pcm_out_valid   : out    vl_logic;
        pcm_out_ready   : in     vl_logic;
        ipcm_out        : out    vl_logic_vector(15 downto 0);
        qpcm_out        : out    vl_logic_vector(15 downto 0);
        clk_2           : in     vl_logic;
        reg_addr        : in     vl_logic_vector;
        reg_rd          : in     vl_logic;
        reg_wr          : in     vl_logic;
        reg_ready       : out    vl_logic;
        reg_writedata   : in     vl_logic_vector(31 downto 0);
        reg_readdata    : out    vl_logic_vector(31 downto 0);
        sin_length      : in     vl_logic_vector;
        resync          : in     vl_logic;
        status          : out    vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of pcmaw : constant is 1;
    attribute mti_svvh_generic_type of UNIT1 : constant is 1;
end sincos_mem;
