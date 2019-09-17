library verilog;
use verilog.vl_types.all;
entity test_mix_freq is
    generic(
        CHANNEL         : integer := 1;
        pcmaw           : integer := 10
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CHANNEL : constant is 1;
    attribute mti_svvh_generic_type of pcmaw : constant is 1;
end test_mix_freq;
