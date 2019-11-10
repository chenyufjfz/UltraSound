library verilog;
use verilog.vl_types.all;
entity sdio_master is
    generic(
        AW              : integer := 8
    );
    port(
        clk_2           : in     vl_logic;
        rst             : in     vl_logic;
        reg_addr        : in     vl_logic_vector;
        reg_writedata   : in     vl_logic_vector(31 downto 0);
        reg_rd_sdio     : in     vl_logic;
        reg_wr_sdio     : in     vl_logic;
        reg_ready_sdio  : out    vl_logic;
        reg_readdata_sdio: out    vl_logic_vector(31 downto 0);
        sdio_miso       : in     vl_logic;
        sdio_mosi       : out    vl_logic;
        sdio_sck        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of AW : constant is 1;
end sdio_master;
