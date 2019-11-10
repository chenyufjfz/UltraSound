library verilog;
use verilog.vl_types.all;
entity arp_cache is
    generic(
        CACHE_ADDR_WIDTH: integer := 9
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        query_request_valid: in     vl_logic;
        query_request_ready: out    vl_logic;
        query_request_ip: in     vl_logic_vector(31 downto 0);
        query_response_valid: out    vl_logic;
        query_response_ready: in     vl_logic;
        query_response_error: out    vl_logic;
        query_response_mac: out    vl_logic_vector(47 downto 0);
        write_request_valid: in     vl_logic;
        write_request_ready: out    vl_logic;
        write_request_ip: in     vl_logic_vector(31 downto 0);
        write_request_mac: in     vl_logic_vector(47 downto 0);
        clear_cache     : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CACHE_ADDR_WIDTH : constant is 1;
end arp_cache;
