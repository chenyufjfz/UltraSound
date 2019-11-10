library verilog;
use verilog.vl_types.all;
entity mix_freq_mc is
    generic(
        CHANNEL         : integer := 8;
        pcmaw           : integer := 12
    );
    port(
        rst             : in     vl_logic;
        clk1            : in     vl_logic;
        pcm_clk         : in     vl_logic;
        ad_pcm_in_valid : in     vl_logic_vector;
        ad_pcm_in_ready : out    vl_logic_vector;
        ad_pcm_in       : in     vl_logic_vector;
        da_lb_pcm_in_valid: in     vl_logic_vector;
        da_lb_pcm_in_ready: out    vl_logic_vector;
        da_lb_pcm_in    : in     vl_logic_vector;
        ipcm_dec_out_valid: out    vl_logic_vector;
        ipcm_dec_out_ready: in     vl_logic_vector;
        ipcm_dec_out    : out    vl_logic_vector;
        ipcm_acc_out    : out    vl_logic_vector;
        qpcm_dec_out_valid: out    vl_logic_vector;
        qpcm_dec_out_ready: in     vl_logic_vector;
        qpcm_dec_out    : out    vl_logic_vector;
        qpcm_acc_out    : out    vl_logic_vector;
        iqpcm_dump_valid: out    vl_logic_vector;
        iqpcm_dump      : out    vl_logic_vector;
        clk_2           : in     vl_logic;
        reg_addr        : in     vl_logic_vector(12 downto 0);
        reg_rd          : in     vl_logic;
        reg_wr          : in     vl_logic;
        reg_ready       : out    vl_logic;
        reg_writedata   : in     vl_logic_vector(31 downto 0);
        reg_readdata    : out    vl_logic_vector(31 downto 0);
        pcm_out_shift   : in     vl_logic_vector(3 downto 0);
        choose_lb       : in     vl_logic;
        dec_rate        : in     vl_logic_vector(7 downto 0);
        dec_rate2       : in     vl_logic_vector(7 downto 0);
        acc_shift       : in     vl_logic_vector(3 downto 0);
        sin_length      : in     vl_logic_vector;
        cycle_num       : in     vl_logic_vector(23 downto 0);
        status          : out    vl_logic_vector(31 downto 0);
        resync          : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CHANNEL : constant is 1;
    attribute mti_svvh_generic_type of pcmaw : constant is 1;
end mix_freq_mc;
