library verilog;
use verilog.vl_types.all;
entity test_mf2_dac2 is
    generic(
        CHANNEL         : integer := 2;
        FREQ_NUM        : integer := 2;
        MIX_NUM         : integer := 1;
        pcmaw           : integer := 10
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CHANNEL : constant is 1;
    attribute mti_svvh_generic_type of FREQ_NUM : constant is 1;
    attribute mti_svvh_generic_type of MIX_NUM : constant is 1;
    attribute mti_svvh_generic_type of pcmaw : constant is 1;
end test_mf2_dac2;
