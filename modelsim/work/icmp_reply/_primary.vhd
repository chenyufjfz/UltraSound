library verilog;
use verilog.vl_types.all;
entity icmp_reply is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        m_icmp_ip_hdr_valid: out    vl_logic;
        m_icmp_ip_hdr_ready: in     vl_logic;
        m_icmp_ip_dscp  : out    vl_logic_vector(5 downto 0);
        m_icmp_ip_ecn   : out    vl_logic_vector(1 downto 0);
        m_icmp_ip_length: out    vl_logic_vector(15 downto 0);
        m_icmp_ip_ttl   : out    vl_logic_vector(7 downto 0);
        m_icmp_ip_protocol: out    vl_logic_vector(7 downto 0);
        m_icmp_source_ip: out    vl_logic_vector(31 downto 0);
        m_icmp_dest_ip  : out    vl_logic_vector(31 downto 0);
        m_icmp_payload_axis_tdata: out    vl_logic_vector(7 downto 0);
        m_icmp_payload_axis_tvalid: out    vl_logic;
        m_icmp_payload_axis_tready: in     vl_logic;
        m_icmp_payload_axis_tlast: out    vl_logic;
        m_icmp_payload_axis_tuser: out    vl_logic;
        s_icmp_ip_hdr_valid: in     vl_logic;
        s_icmp_ip_hdr_ready: out    vl_logic;
        s_icmp_ip_length: in     vl_logic_vector(15 downto 0);
        s_icmp_ip_protocol: in     vl_logic_vector(7 downto 0);
        s_icmp_source_ip: in     vl_logic_vector(31 downto 0);
        s_icmp_dest_ip  : in     vl_logic_vector(31 downto 0);
        s_icmp_payload_axis_tdata: in     vl_logic_vector(7 downto 0);
        s_icmp_payload_axis_tvalid: in     vl_logic;
        s_icmp_payload_axis_tready: out    vl_logic;
        s_icmp_payload_axis_tlast: in     vl_logic;
        unknow_rx_ip_counter: out    vl_logic_vector(23 downto 0);
        icmp_counter    : out    vl_logic_vector(15 downto 0);
        clear_counter   : in     vl_logic;
        local_ip        : in     vl_logic_vector(31 downto 0)
    );
end icmp_reply;
