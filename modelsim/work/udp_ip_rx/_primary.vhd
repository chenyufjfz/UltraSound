library verilog;
use verilog.vl_types.all;
entity udp_ip_rx is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        s_ip_hdr_valid  : in     vl_logic;
        s_ip_hdr_ready  : out    vl_logic;
        s_eth_dest_mac  : in     vl_logic_vector(47 downto 0);
        s_eth_src_mac   : in     vl_logic_vector(47 downto 0);
        s_eth_type      : in     vl_logic_vector(15 downto 0);
        s_ip_version    : in     vl_logic_vector(3 downto 0);
        s_ip_ihl        : in     vl_logic_vector(3 downto 0);
        s_ip_dscp       : in     vl_logic_vector(5 downto 0);
        s_ip_ecn        : in     vl_logic_vector(1 downto 0);
        s_ip_length     : in     vl_logic_vector(15 downto 0);
        s_ip_identification: in     vl_logic_vector(15 downto 0);
        s_ip_flags      : in     vl_logic_vector(2 downto 0);
        s_ip_fragment_offset: in     vl_logic_vector(12 downto 0);
        s_ip_ttl        : in     vl_logic_vector(7 downto 0);
        s_ip_protocol   : in     vl_logic_vector(7 downto 0);
        s_ip_header_checksum: in     vl_logic_vector(15 downto 0);
        s_ip_source_ip  : in     vl_logic_vector(31 downto 0);
        s_ip_dest_ip    : in     vl_logic_vector(31 downto 0);
        s_ip_payload_axis_tdata: in     vl_logic_vector(7 downto 0);
        s_ip_payload_axis_tvalid: in     vl_logic;
        s_ip_payload_axis_tready: out    vl_logic;
        s_ip_payload_axis_tlast: in     vl_logic;
        s_ip_payload_axis_tuser: in     vl_logic;
        m_udp_hdr_valid : out    vl_logic;
        m_udp_hdr_ready : in     vl_logic;
        m_eth_dest_mac  : out    vl_logic_vector(47 downto 0);
        m_eth_src_mac   : out    vl_logic_vector(47 downto 0);
        m_eth_type      : out    vl_logic_vector(15 downto 0);
        m_ip_version    : out    vl_logic_vector(3 downto 0);
        m_ip_ihl        : out    vl_logic_vector(3 downto 0);
        m_ip_dscp       : out    vl_logic_vector(5 downto 0);
        m_ip_ecn        : out    vl_logic_vector(1 downto 0);
        m_ip_length     : out    vl_logic_vector(15 downto 0);
        m_ip_identification: out    vl_logic_vector(15 downto 0);
        m_ip_flags      : out    vl_logic_vector(2 downto 0);
        m_ip_fragment_offset: out    vl_logic_vector(12 downto 0);
        m_ip_ttl        : out    vl_logic_vector(7 downto 0);
        m_ip_protocol   : out    vl_logic_vector(7 downto 0);
        m_ip_header_checksum: out    vl_logic_vector(15 downto 0);
        m_ip_source_ip  : out    vl_logic_vector(31 downto 0);
        m_ip_dest_ip    : out    vl_logic_vector(31 downto 0);
        m_udp_source_port: out    vl_logic_vector(15 downto 0);
        m_udp_dest_port : out    vl_logic_vector(15 downto 0);
        m_udp_length    : out    vl_logic_vector(15 downto 0);
        m_udp_checksum  : out    vl_logic_vector(15 downto 0);
        m_udp_payload_axis_tdata: out    vl_logic_vector(7 downto 0);
        m_udp_payload_axis_tvalid: out    vl_logic;
        m_udp_payload_axis_tready: in     vl_logic;
        m_udp_payload_axis_tlast: out    vl_logic;
        m_udp_payload_axis_tuser: out    vl_logic;
        busy            : out    vl_logic;
        error_header_early_termination: out    vl_logic;
        error_payload_early_termination: out    vl_logic
    );
end udp_ip_rx;