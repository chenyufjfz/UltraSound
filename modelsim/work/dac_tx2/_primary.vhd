library verilog;
use verilog.vl_types.all;
entity dac_tx2 is
    generic(
        CHANNEL         : integer := 8;
        FREQ_NUM        : integer := 6;
        MIX_NUM         : integer := 3;
        sita_w          : integer := 16
    );
    port(
        rst             : in     vl_logic;
        clk1            : in     vl_logic;
        da_clk          : in     vl_logic;
        ipcm_in         : in     vl_logic_vector;
        qpcm_in         : in     vl_logic_vector;
        iqpcm_valid     : in     vl_logic;
        dac_pcm_out_valid: out    vl_logic_vector;
        dac_pcm_out     : out    vl_logic_vector;
        cos_sita        : in     vl_logic_vector;
        sin_sita        : in     vl_logic_vector;
        choose          : in     vl_logic_vector;
        err_clr         : in     vl_logic_vector;
        err             : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CHANNEL : constant is 1;
    attribute mti_svvh_generic_type of FREQ_NUM : constant is 1;
    attribute mti_svvh_generic_type of MIX_NUM : constant is 1;
    attribute mti_svvh_generic_type of sita_w : constant is 1;
end dac_tx2;
