library verilog;
use verilog.vl_types.all;
entity encoder is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        Encoder_A       : in     vl_logic;
        Encoder_B       : in     vl_logic;
        Encoder_dir     : in     vl_logic;
        capture_start   : in     vl_logic;
        Encoder_div_number: in     vl_logic;
        o_encoder_cnt_div_a: out    vl_logic_vector(31 downto 0)
    );
end encoder;
