library verilog;
use verilog.vl_types.all;
entity iq_buf is
    generic(
        ADC_CHANNEL     : integer := 8;
        FREQ_NUM        : integer := 5;
        BUF_NUM         : integer := 80
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        mf_ipcm_acc_out : in     vl_logic_vector;
        mf_qpcm_acc_out : in     vl_logic_vector;
        sync_slot       : in     vl_logic_vector(31 downto 0);
        sync_encoder1   : in     vl_logic_vector(31 downto 0);
        sync_encoder2   : in     vl_logic_vector(31 downto 0);
        mf_iq_read      : in     vl_logic;
        iq_buf_write    : out    vl_logic_vector(15 downto 0);
        iq_buf_rst      : in     vl_logic;
        reg_addr        : in     vl_logic_vector(15 downto 0);
        reg_readdata    : out    vl_logic_vector(31 downto 0);
        reg_rd          : in     vl_logic;
        reg_ready       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADC_CHANNEL : constant is 1;
    attribute mti_svvh_generic_type of FREQ_NUM : constant is 1;
    attribute mti_svvh_generic_type of BUF_NUM : constant is 1;
end iq_buf;
