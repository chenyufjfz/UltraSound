library verilog;
use verilog.vl_types.all;
entity lfsr is
    generic(
        LFSR_WIDTH      : integer := 31;
        LFSR_POLY       : vl_logic_vector(0 to 30) := (Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1);
        LFSR_CONFIG     : string  := "FIBONACCI";
        LFSR_FEED_FORWARD: integer := 0;
        REVERSE         : integer := 0;
        DATA_WIDTH      : integer := 8;
        STYLE           : string  := "AUTO"
    );
    port(
        data_in         : in     vl_logic_vector;
        state_in        : in     vl_logic_vector;
        data_out        : out    vl_logic_vector;
        state_out       : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of LFSR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of LFSR_POLY : constant is 1;
    attribute mti_svvh_generic_type of LFSR_CONFIG : constant is 1;
    attribute mti_svvh_generic_type of LFSR_FEED_FORWARD : constant is 1;
    attribute mti_svvh_generic_type of REVERSE : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of STYLE : constant is 1;
end lfsr;
