library verilog;
use verilog.vl_types.all;
entity priority_encoder is
    generic(
        WIDTH           : integer := 4;
        LSB_PRIORITY    : string  := "LOW"
    );
    port(
        input_unencoded : in     vl_logic_vector;
        output_valid    : out    vl_logic;
        output_encoded  : out    vl_logic_vector;
        output_unencoded: out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH : constant is 1;
    attribute mti_svvh_generic_type of LSB_PRIORITY : constant is 1;
end priority_encoder;
