library verilog;
use verilog.vl_types.all;
entity dac_tx is
    generic(
        CHANNEL         : integer := 3;
        pcmaw           : integer := 10
    );
    port(
        pcm_clk         : in     vl_logic;
        rst             : in     vl_logic;
        dac_pcm_out_valid: out    vl_logic_vector;
        dac_pcm_out_ready: in     vl_logic_vector;
        dac_pcm_out     : out    vl_logic_vector;
        clk_2           : in     vl_logic;
        reg_addr        : in     vl_logic_vector(15 downto 0);
        reg_rd          : in     vl_logic;
        reg_wr          : in     vl_logic;
        reg_ready       : out    vl_logic;
        reg_writedata   : in     vl_logic_vector(31 downto 0);
        reg_readdata    : out    vl_logic_vector(31 downto 0);
        dac_signal_len  : in     vl_logic_vector;
        dac_cic_rate    : in     vl_logic_vector;
        dac_run         : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CHANNEL : constant is 1;
    attribute mti_svvh_generic_type of pcmaw : constant is 1;
end dac_tx;
