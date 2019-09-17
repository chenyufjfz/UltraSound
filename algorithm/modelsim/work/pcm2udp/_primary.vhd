library verilog;
use verilog.vl_types.all;
entity pcm2udp is
    generic(
        CHANNEL         : integer := 3;
        pcmaw           : integer := 10;
        PCM_UDP_PACKET_TYPE: vl_logic_vector(0 to 7) := (Hi1, Hi1, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        pcm_in_clk      : in     vl_logic;
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        pcm_in_valid    : in     vl_logic_vector;
        pcm_in          : in     vl_logic_vector;
        pcm_udp_hdr_valid: out    vl_logic;
        pcm_udp_hdr_ready: in     vl_logic;
        pcm_udp_length  : out    vl_logic_vector(15 downto 0);
        pcm_udp_payload_axis_tdata: out    vl_logic_vector(7 downto 0);
        pcm_udp_payload_axis_tvalid: out    vl_logic;
        pcm_udp_payload_axis_tready: in     vl_logic;
        pcm_udp_payload_axis_tlast: out    vl_logic;
        pcm_udp_tx_left : out    vl_logic_vector(23 downto 0);
        pcm_udp_tx_start: in     vl_logic;
        pcm_udp_tx_total: in     vl_logic_vector(23 downto 0);
        pcm_udp_tx_th   : in     vl_logic_vector(7 downto 0);
        pcm_udp_channel_choose: in     vl_logic_vector(7 downto 0);
        pcm_udp_capture_sep: in     vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CHANNEL : constant is 1;
    attribute mti_svvh_generic_type of pcmaw : constant is 1;
    attribute mti_svvh_generic_type of PCM_UDP_PACKET_TYPE : constant is 1;
end pcm2udp;
