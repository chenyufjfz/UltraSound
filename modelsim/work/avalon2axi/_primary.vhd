library verilog;
use verilog.vl_types.all;
entity avalon2axi is
    generic(
        DATAWIDTH       : integer := 8;
        MAX_READY_LATENCY: integer := 2;
        QUEUE_IDX_LEN   : integer := 1
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        sop             : in     vl_logic;
        eop             : in     vl_logic;
        data            : in     vl_logic_vector;
        rdy             : out    vl_logic;
        dval            : in     vl_logic;
        axi_data        : out    vl_logic_vector;
        axi_valid       : out    vl_logic;
        axi_rdy         : in     vl_logic;
        axi_last        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATAWIDTH : constant is 1;
    attribute mti_svvh_generic_type of MAX_READY_LATENCY : constant is 1;
    attribute mti_svvh_generic_type of QUEUE_IDX_LEN : constant is 1;
end avalon2axi;
