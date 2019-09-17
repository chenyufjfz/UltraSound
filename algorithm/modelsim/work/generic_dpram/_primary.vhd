library verilog;
use verilog.vl_types.all;
entity generic_dpram is
    generic(
        adw             : integer := 16;
        aaw             : integer := 9;
        bdw             : integer := 32;
        pipeline        : integer := 1
    );
    port(
        address_a       : in     vl_logic_vector;
        address_b       : in     vl_logic_vector;
        clock_a         : in     vl_logic;
        clock_b         : in     vl_logic;
        data_a          : in     vl_logic_vector;
        data_b          : in     vl_logic_vector;
        rden_a          : in     vl_logic;
        rden_b          : in     vl_logic;
        wren_a          : in     vl_logic;
        wren_b          : in     vl_logic;
        q_a             : out    vl_logic_vector;
        q_b             : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of adw : constant is 1;
    attribute mti_svvh_generic_type of aaw : constant is 1;
    attribute mti_svvh_generic_type of bdw : constant is 1;
    attribute mti_svvh_generic_type of pipeline : constant is 1;
end generic_dpram;
