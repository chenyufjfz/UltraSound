library verilog;
use verilog.vl_types.all;
entity sdio_slave is
    generic(
        AW              : integer := 8
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        sdio_addr       : out    vl_logic_vector;
        sdio_writedata  : out    vl_logic_vector(31 downto 0);
        sdio_rd         : out    vl_logic;
        sdio_wr         : out    vl_logic;
        sdio_readdata   : in     vl_logic_vector(31 downto 0);
        sdio_miso       : out    vl_logic;
        sdio_mosi       : in     vl_logic;
        sdio_sck        : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of AW : constant is 1;
end sdio_slave;
