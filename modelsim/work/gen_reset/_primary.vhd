library verilog;
use verilog.vl_types.all;
entity gen_reset is
    generic(
        CTR_WIDTH       : integer := 16
    );
    port(
        clk             : in     vl_logic;
        reset_n_in      : in     vl_logic;
        reset_out       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CTR_WIDTH : constant is 1;
end gen_reset;
