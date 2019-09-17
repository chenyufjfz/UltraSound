library verilog;
use verilog.vl_types.all;
entity synchronizer is
    generic(
        DEPTH           : integer := 2
    );
    port(
        reset           : in     vl_logic;
        clk             : in     vl_logic;
        d               : in     vl_logic;
        q               : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DEPTH : constant is 1;
end synchronizer;
