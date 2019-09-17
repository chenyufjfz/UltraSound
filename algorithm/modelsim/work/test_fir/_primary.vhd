library verilog;
use verilog.vl_types.all;
entity test_fir is
    generic(
        CHANNEL         : integer := 3;
        FIR_LANE        : integer := 16;
        acw             : integer := 31;
        pcmaw           : integer := 10;
        mul_num         : integer := 2;
        PARAM_SHADOW_RAM: integer := 1
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CHANNEL : constant is 1;
    attribute mti_svvh_generic_type of FIR_LANE : constant is 1;
    attribute mti_svvh_generic_type of acw : constant is 1;
    attribute mti_svvh_generic_type of pcmaw : constant is 1;
    attribute mti_svvh_generic_type of mul_num : constant is 1;
    attribute mti_svvh_generic_type of PARAM_SHADOW_RAM : constant is 1;
end test_fir;
