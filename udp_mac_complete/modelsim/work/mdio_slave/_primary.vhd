library verilog;
use verilog.vl_types.all;
entity mdio_slave is
    port(
        reset           : in     vl_logic;
        mdc             : in     vl_logic;
        mdio            : inout  vl_logic;
        dev_addr        : in     vl_logic_vector(4 downto 0);
        reg_addr        : out    vl_logic_vector(4 downto 0);
        reg_read        : out    vl_logic;
        reg_write       : out    vl_logic;
        reg_dout        : out    vl_logic_vector(15 downto 0);
        reg_din         : in     vl_logic_vector(15 downto 0)
    );
end mdio_slave;
