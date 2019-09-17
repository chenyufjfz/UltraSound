library verilog;
use verilog.vl_types.all;
entity glitch_remove is
    generic(
        CTR_WIDTH       : integer := 20
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        glitch_in       : in     vl_logic;
        glitch_free_out : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CTR_WIDTH : constant is 1;
end glitch_remove;
