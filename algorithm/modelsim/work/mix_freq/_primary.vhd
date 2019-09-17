library verilog;
use verilog.vl_types.all;
entity mix_freq is
    port(
        rst             : in     vl_logic;
        clk1            : in     vl_logic;
        pcm_clk         : in     vl_logic;
        ad_pcm_in_valid : in     vl_logic;
        ad_pcm_in_ready : out    vl_logic;
        ad_pcm_in       : in     vl_logic_vector(15 downto 0);
        da_lb_pcm_in_valid: in     vl_logic;
        da_lb_pcm_in_ready: out    vl_logic;
        da_lb_pcm_in    : in     vl_logic_vector(15 downto 0);
        ipcm_in         : in     vl_logic_vector(15 downto 0);
        qpcm_in         : in     vl_logic_vector(15 downto 0);
        iq_next         : out    vl_logic;
        ipcm_dec_out_valid: out    vl_logic;
        ipcm_dec_out_ready: in     vl_logic;
        ipcm_dec_out    : out    vl_logic_vector(15 downto 0);
        ipcm_acc_out    : out    vl_logic_vector(31 downto 0);
        qpcm_dec_out_valid: out    vl_logic;
        qpcm_dec_out_ready: in     vl_logic;
        qpcm_dec_out    : out    vl_logic_vector(15 downto 0);
        qpcm_acc_out    : out    vl_logic_vector(31 downto 0);
        iqpcm_dump_valid: out    vl_logic;
        iqpcm_dump      : out    vl_logic_vector(15 downto 0);
        pcm_out_shift   : in     vl_logic_vector(3 downto 0);
        choose_lb       : in     vl_logic;
        dec_rate        : in     vl_logic_vector(7 downto 0);
        dec_rate2       : in     vl_logic_vector(7 downto 0);
        acc_clr         : in     vl_logic;
        acc_shift       : in     vl_logic_vector(3 downto 0)
    );
end mix_freq;
