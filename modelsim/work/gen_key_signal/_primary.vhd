library verilog;
use verilog.vl_types.all;
entity gen_key_signal is
    generic(
        CTR_WIDTH       : integer := 22
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        key_in_n        : in     vl_logic;
        key_out         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CTR_WIDTH : constant is 1;
end gen_key_signal;
