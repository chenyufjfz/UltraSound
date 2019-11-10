library verilog;
use verilog.vl_types.all;
entity test_udp_mac_complete is
    generic(
        ETH_SPEED       : integer := 1000;
        ETH_CLK_DELAY   : vl_notype
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ETH_SPEED : constant is 1;
    attribute mti_svvh_generic_type of ETH_CLK_DELAY : constant is 3;
end test_udp_mac_complete;
