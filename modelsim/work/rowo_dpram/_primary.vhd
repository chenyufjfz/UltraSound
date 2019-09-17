library verilog;
use verilog.vl_types.all;
entity rowo_dpram is
    generic(
        rdw             : integer := 32;
        raw             : integer := 8;
        wdw             : integer := 32;
        wsize           : vl_notype;
        pipeline        : integer := 1
    );
    port(
        data            : in     vl_logic_vector;
        rdaddress       : in     vl_logic_vector;
        rden            : in     vl_logic;
        rdclock         : in     vl_logic;
        wraddress       : in     vl_logic_vector;
        wrclock         : in     vl_logic;
        wren            : in     vl_logic;
        q               : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of rdw : constant is 1;
    attribute mti_svvh_generic_type of raw : constant is 1;
    attribute mti_svvh_generic_type of wdw : constant is 1;
    attribute mti_svvh_generic_type of wsize : constant is 3;
    attribute mti_svvh_generic_type of pipeline : constant is 1;
end rowo_dpram;
