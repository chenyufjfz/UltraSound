library verilog;
use verilog.vl_types.all;
entity mult is
    generic(
        di1             : integer := 16;
        di2             : integer := 16;
        dow             : integer := 32;
        pipeline        : integer := 2
    );
    port(
        clock           : in     vl_logic;
        dataa           : in     vl_logic_vector;
        datab           : in     vl_logic_vector;
        result          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of di1 : constant is 1;
    attribute mti_svvh_generic_type of di2 : constant is 1;
    attribute mti_svvh_generic_type of dow : constant is 1;
    attribute mti_svvh_generic_type of pipeline : constant is 1;
end mult;
