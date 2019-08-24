library verilog;
use verilog.vl_types.all;
entity test_execcmd is
    generic(
        AW              : integer := 10
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of AW : constant is 1;
end test_execcmd;
