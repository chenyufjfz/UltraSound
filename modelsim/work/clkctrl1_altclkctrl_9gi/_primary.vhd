library verilog;
use verilog.vl_types.all;
entity clkctrl1_altclkctrl_9gi is
    port(
        clkselect       : in     vl_logic_vector(1 downto 0);
        ena             : in     vl_logic;
        inclk           : in     vl_logic_vector(3 downto 0);
        outclk          : out    vl_logic
    );
end clkctrl1_altclkctrl_9gi;
