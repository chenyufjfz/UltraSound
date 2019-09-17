library verilog;
use verilog.vl_types.all;
entity arp_eth_tx is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        s_frame_valid   : in     vl_logic;
        s_frame_ready   : out    vl_logic;
        s_eth_dest_mac  : in     vl_logic_vector(47 downto 0);
        s_eth_src_mac   : in     vl_logic_vector(47 downto 0);
        s_eth_type      : in     vl_logic_vector(15 downto 0);
        s_arp_htype     : in     vl_logic_vector(15 downto 0);
        s_arp_ptype     : in     vl_logic_vector(15 downto 0);
        s_arp_oper      : in     vl_logic_vector(15 downto 0);
        s_arp_sha       : in     vl_logic_vector(47 downto 0);
        s_arp_spa       : in     vl_logic_vector(31 downto 0);
        s_arp_tha       : in     vl_logic_vector(47 downto 0);
        s_arp_tpa       : in     vl_logic_vector(31 downto 0);
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
        busy            : out    vl_logic
    );
end arp_eth_tx;
