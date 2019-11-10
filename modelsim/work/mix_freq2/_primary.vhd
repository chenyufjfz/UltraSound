library verilog;
use verilog.vl_types.all;
entity mix_freq2 is
    port(
        rst             : in     vl_logic;
        clk1            : in     vl_logic;
        ad_clk          : in     vl_logic;
        ad_pcm_in_valid : in     vl_logic;
        ad_pcm_in       : in     vl_logic_vector(15 downto 0);
        da_lb_pcm_in_valid: in     vl_logic;
        da_lb_pcm_in    : in     vl_logic_vector(15 downto 0);
        ipcm_in         : in     vl_logic_vector(15 downto 0);
        qpcm_in         : in     vl_logic_vector(15 downto 0);
        iqpcm_valid     : in     vl_logic;
        ad_valid        : in     vl_logic;
        ipcm_acc_out    : out    vl_logic_vector(31 downto 0);
        qpcm_acc_out    : out    vl_logic_vector(31 downto 0);
        choose_lb       : in     vl_logic;
        acc_shift       : in     vl_logic_vector(3 downto 0);
        cycle_num       : in     vl_logic_vector(23 downto 0);
        err_clr         : in     vl_logic;
        err             : out    vl_logic_vector(1 downto 0)
    );
end mix_freq2;
