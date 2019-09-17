library verilog;
use verilog.vl_types.all;
entity eth_axis_rx is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        s_axis_tdata    : in     vl_logic_vector(7 downto 0);
        s_axis_tvalid   : in     vl_logic;
        s_axis_tready   : out    vl_logic;
        s_axis_tlast    : in     vl_logic;
        s_axis_tuser    : in     vl_logic;
        m_eth_hdr_valid : out    vl_logic;
        m_eth_hdr_ready : in     vl_logic;
        m_eth_dest_mac  : out    vl_logic_vector(47 downto 0);
        m_eth_src_mac   : out    vl_logic_vector(47 downto 0);
        m_eth_type      : out    vl_logic_vector(15 downto 0);
        m_eth_payload_axis_tdata: out    vl_logic_vector(7 downto 0);
        m_eth_payload_axis_tvalid: out    vl_logic;
        m_eth_payload_axis_tready: in     vl_logic;
        m_eth_payload_axis_tlast: out    vl_logic;
        m_eth_payload_axis_tuser: out    vl_logic;
        busy            : out    vl_logic;
        error_header_early_termination: out    vl_logic
    );
end eth_axis_rx;
