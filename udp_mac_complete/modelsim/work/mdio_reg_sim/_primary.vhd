library verilog;
use verilog.vl_types.all;
entity mdio_reg_sim is
    port(
        reset           : in     vl_logic;
        clk             : in     vl_logic;
        reg_addr        : in     vl_logic_vector(4 downto 0);
        reg_write       : in     vl_logic;
        reg_read        : in     vl_logic;
        reg_dout        : out    vl_logic_vector(15 downto 0);
        reg_din         : in     vl_logic_vector(15 downto 0);
        conf_done       : out    vl_logic
    );
end mdio_reg_sim;
