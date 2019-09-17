library verilog;
use verilog.vl_types.all;
entity clkctrl1 is
    port(
        clkselect       : in     vl_logic;
        inclk0x         : in     vl_logic;
        inclk1x         : in     vl_logic;
        outclk          : out    vl_logic
    );
end clkctrl1;
