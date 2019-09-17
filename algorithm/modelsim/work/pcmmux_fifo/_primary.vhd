library verilog;
use verilog.vl_types.all;
entity pcmmux_fifo is
    generic(
        CHANNEL         : integer := 3;
        pcmaw           : integer := 9
    );
    port(
        pcm_in_clk      : in     vl_logic;
        pcm_out_clk     : in     vl_logic;
        rst             : in     vl_logic;
        pcm_in_valid    : in     vl_logic_vector;
        pcm_in_ready    : out    vl_logic_vector;
        pcm_in          : in     vl_logic_vector;
        pcm_out_valid   : out    vl_logic;
        pcm_out_ready   : in     vl_logic;
        pcm_out         : out    vl_logic_vector(15 downto 0);
        pcm_channel_choose: in     vl_logic_vector(7 downto 0);
        pcm_available   : out    vl_logic_vector;
        pcm_capture_sep : in     vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CHANNEL : constant is 1;
    attribute mti_svvh_generic_type of pcmaw : constant is 1;
end pcmmux_fifo;
