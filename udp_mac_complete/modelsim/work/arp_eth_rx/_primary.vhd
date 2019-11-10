library verilog;
use verilog.vl_types.all;
entity arp_eth_rx is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        s_eth_hdr_valid : in     vl_logic;
        s_eth_hdr_ready : out    vl_logic;
        s_eth_dest_mac  : in     vl_logic_vector(47 downto 0);
        s_eth_src_mac   : in     vl_logic_vector(47 downto 0);
        s_eth_type      : in     vl_logic_vector(15 downto 0);
        s_eth_payload_axis_tdata: in     vl_logic_vector(7 downto 0);
        s_eth_payload_axis_tvalid: in     vl_logic;
        s_eth_payload_axis_tready: out    vl_logic;
        s_eth_payload_axis_tlast: in     vl_logic;
        s_eth_payload_axis_tuser: in     vl_logic;
        m_frame_valid   : out    vl_logic;
        m_frame_ready   : in     vl_logic;
        m_eth_dest_mac  : out    vl_logic_vector(47 downto 0);
        m_eth_src_mac   : out    vl_logic_vector(47 downto 0);
        m_eth_type      : out    vl_logic_vector(15 downto 0);
        m_arp_htype     : out    vl_logic_vector(15 downto 0);
        m_arp_ptype     : out    vl_logic_vector(15 downto 0);
        m_arp_hlen      : out    vl_logic_vector(7 downto 0);
        m_arp_plen      : out    vl_logic_vector(7 downto 0);
        m_arp_oper      : out    vl_logic_vector(15 downto 0);
        m_arp_sha       : out    vl_logic_vector(47 downto 0);
        m_arp_spa       : out    vl_logic_vector(31 downto 0);
        m_arp_tha       : out    vl_logic_vector(47 downto 0);
        m_arp_tpa       : out    vl_logic_vector(31 downto 0);
        busy            : out    vl_logic;
        error_header_early_termination: out    vl_logic;
        error_invalid_header: out    vl_logic
    );
end arp_eth_rx;
