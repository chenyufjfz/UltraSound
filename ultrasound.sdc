create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]
derive_pll_clocks
derive_clock_uncertainty
create_clock -name ENET0_RX_CLK -period 8 [get_ports {ENET0_RX_CLK}]