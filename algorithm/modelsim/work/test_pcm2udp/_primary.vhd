library verilog;
use verilog.vl_types.all;
entity test_pcm2udp is
    generic(
        pcmaw           : integer := 10
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of pcmaw : constant is 1;
end test_pcm2udp;
