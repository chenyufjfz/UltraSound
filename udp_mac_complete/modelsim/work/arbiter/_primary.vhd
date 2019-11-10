library verilog;
use verilog.vl_types.all;
entity arbiter is
    generic(
        PORTS           : integer := 4;
        \TYPE\          : string  := "PRIORITY";
        \BLOCK\         : string  := "NONE";
        LSB_PRIORITY    : string  := "LOW"
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        request         : in     vl_logic_vector;
        acknowledge     : in     vl_logic_vector;
        grant           : out    vl_logic_vector;
        grant_valid     : out    vl_logic;
        grant_encoded   : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PORTS : constant is 1;
    attribute mti_svvh_generic_type of \TYPE\ : constant is 1;
    attribute mti_svvh_generic_type of \BLOCK\ : constant is 1;
    attribute mti_svvh_generic_type of LSB_PRIORITY : constant is 1;
end arbiter;
