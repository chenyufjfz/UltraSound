library verilog;
use verilog.vl_types.all;
entity generic_spram is
    generic(
        SIMULATION      : integer := 1;
        aw              : integer := 12;
        dw              : integer := 32;
        wsize           : vl_notype
    );
    port(
        clk             : in     vl_logic;
        re              : in     vl_logic;
        we              : in     vl_logic;
        addr            : in     vl_logic_vector;
        q               : out    vl_logic_vector;
        data            : in     vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SIMULATION : constant is 1;
    attribute mti_svvh_generic_type of aw : constant is 1;
    attribute mti_svvh_generic_type of dw : constant is 1;
    attribute mti_svvh_generic_type of wsize : constant is 3;
end generic_spram;
