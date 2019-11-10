library verilog;
use verilog.vl_types.all;
entity top_mdio_slave is
    port(
        reset           : in     vl_logic;
        mdc             : in     vl_logic;
        mdio            : inout  vl_logic;
        dev_addr        : in     vl_logic_vector(4 downto 0);
        conf_done       : out    vl_logic
    );
end top_mdio_slave;
