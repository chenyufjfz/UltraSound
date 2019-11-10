library verilog;
use verilog.vl_types.all;
entity mix_freq2_mc is
    generic(
        FREQ_NUM        : integer := 6;
        CHANNEL         : integer := 8
    );
    port(
        rst             : in     vl_logic;
        clk1            : in     vl_logic;
        clk_2           : in     vl_logic;
        ad_clk          : in     vl_logic;
        ad_pcm_in_valid : in     vl_logic_vector;
        ad_pcm_in       : in     vl_logic_vector;
        da_lb_pcm_in_valid: in     vl_logic_vector;
        da_lb_pcm_in    : in     vl_logic_vector;
        ipcm_in         : in     vl_logic_vector;
        qpcm_in         : in     vl_logic_vector;
        ad_valid        : in     vl_logic;
        iqpcm_valid     : in     vl_logic;
        mf_ipcm_acc_out : out    vl_logic_vector;
        mf_qpcm_acc_out : out    vl_logic_vector;
        mf_iq_read      : in     vl_logic;
        choose_lb       : in     vl_logic_vector;
        acc_shift       : in     vl_logic_vector;
        cycle_num       : in     vl_logic_vector;
        err_clr         : in     vl_logic_vector;
        err             : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FREQ_NUM : constant is 1;
    attribute mti_svvh_generic_type of CHANNEL : constant is 1;
end mix_freq2_mc;
