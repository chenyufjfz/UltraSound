library verilog;
use verilog.vl_types.all;
entity arp is
    generic(
        CACHE_ADDR_WIDTH: integer := 9;
        REQUEST_RETRY_COUNT: integer := 4;
        REQUEST_RETRY_INTERVAL: integer := 250000000;
        REQUEST_TIMEOUT : integer := -544967296
    );
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
        arp_request_valid: in     vl_logic;
        arp_request_ready: out    vl_logic;
        arp_request_ip  : in     vl_logic_vector(31 downto 0);
        arp_response_valid: out    vl_logic;
        arp_response_ready: in     vl_logic;
        arp_response_error: out    vl_logic;
        arp_response_mac: out    vl_logic_vector(47 downto 0);
        local_mac       : in     vl_logic_vector(47 downto 0);
        local_ip        : in     vl_logic_vector(31 downto 0);
        gateway_ip      : in     vl_logic_vector(31 downto 0);
        subnet_mask     : in     vl_logic_vector(31 downto 0);
        clear_cache     : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CACHE_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of REQUEST_RETRY_COUNT : constant is 1;
    attribute mti_svvh_generic_type of REQUEST_RETRY_INTERVAL : constant is 1;
    attribute mti_svvh_generic_type of REQUEST_TIMEOUT : constant is 1;
end arp;
