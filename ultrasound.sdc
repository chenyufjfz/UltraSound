## Generated SDC file "C:/Users/yuchen/Desktop/UltraSound.out.sdc"

## Copyright (C) 1991-2012 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 12.1 Build 243 01/31/2013 Service Pack 1 SJ Full Version"

## DATE    "Mon Jul 08 18:39:15 2019"

##
## DEVICE  "EP4CE115F29C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3

set IN_CLK_PERIOD	20
# 1000MHz: Period = 8ns		|	 100MHz: Period = 40ns	 |	 10MHz: Period = 400ns 
set CLK_125M_PERIOD	8
set CLK_25M_PERIOD	40

# Default Main Frequency: 100MHz Default Control Frequency: 50MHz

	
set	clk_in				"CLOCK_50"

set	rgmii_rx_125M_virtualclk	"rgmii_rx_125M_virtualclk"
set	rgmii_rx_25M_virtualclk		"rgmii_rx_25M_virtualclk"

set	rgmii_rx_125M_clk	"rgmii_rx_125M_clk"
set	rgmii_rx_25M_clk	"rgmii_rx_25M_clk"

# Change the name of rgmii interface on the top level
set rgmii_tx_clk		"ENET0_GTX_CLK"
set	rgmii_out			"ENET0_TX_DATA"
set	rgmii_tx_control	"ENET0_TX_EN"

set	rgmii_rx_clk		"ENET0_RX_CLK"
set rgmii_in			"ENET0_RX_DATA"
set	rgmii_rx_control	"ENET0_RX_DV"

set da_clk_pin          "DA_CLK_OUT"
set da_pcm              "DA_PCM_OUT"
set da_pcm_t            "DA_PCM_OUT_T"

set ad_clk_pin          "AD_CLK_OUT"
set ad_pcm              "AD_PCM_IN"

# Board Delay
# Assume trace delay, pin capacitance, and rise/fall time differences between data and\
clock are negligible.
set data_delay_max 		0
set data_delay_min		0
set clk_delay_max		0
set clk_delay_min		0 

# External PHY Parameter (Refer to MarvelPHY 88EE1111)
set tsu			1.0
set th			0.8	
set tco_max		0.5	
set tco_min		-0.5

set da_tsu      3
set da_th       2.5

set ad_tco_max   4.9
set ad_tco_min   1.3

#**************************************************************
# Create Clock
#**************************************************************

create_clock -name $clk_in -period $IN_CLK_PERIOD [get_ports $clk_in]

# Create clock with 90 degree shift for center align
create_clock -name $rgmii_rx_125M_clk	-period $CLK_125M_PERIOD \
-waveform "[expr 0.25*$CLK_125M_PERIOD] [expr 0.75*$CLK_125M_PERIOD]" \
[get_ports $rgmii_rx_clk]

create_clock -name $rgmii_rx_25M_clk	-period $CLK_25M_PERIOD \
-waveform "[expr 0.25*$CLK_25M_PERIOD] [expr 0.75*$CLK_25M_PERIOD]" \
[get_ports $rgmii_rx_clk] -add


#**************************************************************
# Virtual Clock
#************************************************************** 
# Virtual Clock is the clock outside the FPGA.  It is also used 
# to differentiate the clock uncertainty between
# Input to Register, Register to Register and Output to Register

create_clock -name $rgmii_rx_125M_virtualclk 	-period $CLK_125M_PERIOD 
create_clock -name $rgmii_rx_25M_virtualclk 	-period $CLK_25M_PERIOD 	


#**************************************************************
# Create Generated Clock
#**************************************************************
create_generated_clock -name clk_2 -source [get_pins {main_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock $clk_in [get_pins {main_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name clk -source [get_pins {main_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 2 -master_clock $clk_in [get_pins {main_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name da_clk -source [get_pins {main_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock $clk_in [get_pins {main_pll_inst|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name ad_clk -source [get_pins {main_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 2 -master_clock $clk_in [get_pins {main_pll_inst|altpll_component|auto_generated|pll1|clk[3]}] 
create_generated_clock -name da_clk_90deg -source [get_pins {main_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -phase 180.000 -master_clock $clk_in [get_pins {main_pll_inst|altpll_component|auto_generated|pll1|clk[4]}]
create_generated_clock -name clk_125M_0deg -source [get_pins {enet_clk_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 5 -divide_by 2 -master_clock $clk_in [get_pins {enet_clk_pll_inst|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name clk_25M_0deg -source [get_pins {enet_clk_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 2 -master_clock $clk_in [get_pins {enet_clk_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] 


# RGMII TX CLOCK
#**************************************************************
# It doesn't use virtual clock as to include the delay generated by
# in the timing analysis

# -phase 90:Tells timing analysis that there is a phase-shift externaly.
# It have no effect inside the FPGA
create_generated_clock -name rgmii_125_tx_clk \
-source [get_pins {enet_clk_pll_inst|altpll_component|auto_generated|pll1|clk[0]}]  \
-master_clock clk_125M_0deg -phase 90 [get_ports $rgmii_tx_clk]

create_generated_clock -name rgmii_25_tx_clk \
-source [get_pins {enet_clk_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] \
-master_clock clk_25M_0deg  -phase 90 [get_ports $rgmii_tx_clk] -add

create_generated_clock -name da_clk_out \
-source [get_pins {main_pll_inst|altpll_component|auto_generated|pll1|clk[4]}] \
-master_clock da_clk_90deg [get_ports $da_clk_pin]

create_generated_clock -name ad_clk_out \
-source [get_pins {main_pll_inst|altpll_component|auto_generated|pll1|clk[3]}] \
-master_clock ad_clk -phase 180 [get_ports $ad_clk_pin]

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -exclusive \
-group "clk_125M_0deg	rgmii_125_tx_clk	$rgmii_rx_125M_clk	$rgmii_rx_125M_virtualclk"  \
-group "clk_25M_0deg	rgmii_25_tx_clk		$rgmii_rx_25M_clk	$rgmii_rx_25M_virtualclk"  \

# Set false path to the design with different domain clock
set_clock_groups -asynchronous \
-group {clk_125M_0deg clk_25M_0deg} \
-group $clk_in \
-group "clk clk_2 da_clk ad_clk" \
-group "$rgmii_rx_125M_clk $rgmii_rx_25M_clk"

#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty -add


#**************************************************************
# Set Output Delay
#**************************************************************

#**************************************************************
# Transmit Side (External PHY Delay is Turn On)
#**************************************************************
# Same Edge Capture Center Align: launch at positive edge and latch at positive edge

# Determine the desired setup and hold relationship in order to
# let TimeQuest analyze only the correct pair of launch-latch setup and hold relationship

set_false_path \
-fall_from [get_clocks "clk_125M_0deg clk_25M_0deg"] \
-rise_to [get_clocks "rgmii_125_tx_clk rgmii_25_tx_clk"] \
-setup

set_false_path \
-rise_from [get_clocks "clk_125M_0deg clk_25M_0deg"] \
-fall_to [get_clocks "rgmii_125_tx_clk rgmii_25_tx_clk"] \
-setup

set_false_path \
-fall_from [get_clocks "clk_125M_0deg clk_25M_0deg"] \
-fall_to [get_clocks "rgmii_125_tx_clk rgmii_25_tx_clk"] \
-hold

set_false_path \
-rise_from [get_clocks "clk_125M_0deg clk_25M_0deg"] \
-rise_to [get_clocks "rgmii_125_tx_clk rgmii_25_tx_clk"] \
-hold

set_false_path -from [get_pins -compatibility_mode *clkctrl1_altclkctrl*select_reg*] -to [get_ports "$rgmii_out* $rgmii_tx_control"]
set_false_path -from [get_pins -compatibility_mode *clkctrl1_altclkctrl*ena_reg*] -to [get_ports "$rgmii_out* $rgmii_tx_control"]

# The formula to calculate the output delay is provided in AN433
set_output_delay -clock rgmii_125_tx_clk \
-max [expr  $data_delay_max + $tsu - $clk_delay_min] \
[get_ports "$rgmii_out* $rgmii_tx_control"] \
-add_delay

set_output_delay -clock rgmii_125_tx_clk \
-max [expr  $data_delay_max + $tsu - $clk_delay_min] \
[get_ports "$rgmii_out* $rgmii_tx_control"] \
-clock_fall \
-add_delay

set_output_delay -clock rgmii_125_tx_clk \
-min [expr  $data_delay_min - $th - $clk_delay_max] \
[get_ports "$rgmii_out* $rgmii_tx_control"] \
-add_delay

set_output_delay -clock rgmii_125_tx_clk \
-min [expr  $data_delay_min - $th - $clk_delay_max] \
[get_ports "$rgmii_out* $rgmii_tx_control"] \
-clock_fall \
-add_delay

set_output_delay -clock rgmii_25_tx_clk \
-max [expr  $data_delay_max + $tsu - $clk_delay_min] \
[get_ports "$rgmii_out* $rgmii_tx_control"] \
-add_delay

set_output_delay -clock rgmii_25_tx_clk \
-max [expr  $data_delay_max + $tsu - $clk_delay_min] \
[get_ports "$rgmii_out* $rgmii_tx_control"] \
-clock_fall \
-add_delay

set_output_delay -clock rgmii_25_tx_clk \
-min [expr  $data_delay_min - $th - $clk_delay_max] \
[get_ports "$rgmii_out* $rgmii_tx_control"] \
-add_delay

set_output_delay -clock rgmii_25_tx_clk \
-min [expr  $data_delay_min - $th - $clk_delay_max] \
[get_ports "$rgmii_out* $rgmii_tx_control"] \
-clock_fall \
-add_delay

set_output_delay -clock da_clk_out \
-max [expr $da_tsu ] \
[get_ports "$da_pcm* $da_pcm_t*"] \
-add_delay

set_output_delay -clock da_clk_out \
-min [expr - $da_th] \
[get_ports "$da_pcm* $da_pcm_t*"] \
-add_delay

#**************************************************************
# Set Input Delay
#**************************************************************


set_false_path \
-fall_from [get_clocks "$rgmii_rx_125M_virtualclk $rgmii_rx_25M_virtualclk"] \
-rise_to [get_clocks "$rgmii_rx_125M_clk $rgmii_rx_25M_clk"] \
-setup

set_false_path \
-rise_from [get_clocks "$rgmii_rx_125M_virtualclk $rgmii_rx_25M_virtualclk"] \
-fall_to [get_clocks "$rgmii_rx_125M_clk $rgmii_rx_25M_clk"] \
-setup

set_false_path \
-fall_from [get_clocks "$rgmii_rx_125M_virtualclk $rgmii_rx_25M_virtualclk"] \
-fall_to [get_clocks "$rgmii_rx_125M_clk $rgmii_rx_25M_clk"] \
-hold

set_false_path \
-rise_from [get_clocks "$rgmii_rx_125M_virtualclk $rgmii_rx_25M_virtualclk"] \
-rise_to [get_clocks "$rgmii_rx_125M_clk $rgmii_rx_25M_clk"] \
-hold

# The formula to calculate the input delay is provided in AN433
 
# Set Input Deday
set_input_delay -clock  [get_clocks $rgmii_rx_125M_virtualclk] \
-max [expr  $data_delay_max + $tco_max - $clk_delay_min] \
[get_ports "$rgmii_in* $rgmii_rx_control"] \
-add_delay

set_input_delay -clock  [get_clocks $rgmii_rx_125M_virtualclk] \
-max [expr  $data_delay_max + $tco_max - $clk_delay_min] \
[get_ports "$rgmii_in* $rgmii_rx_control"] \
-clock_fall \
-add_delay

set_input_delay -clock  [get_clocks $rgmii_rx_125M_virtualclk] \
-min [expr  $data_delay_min + $tco_min - $clk_delay_max] \
[get_ports "$rgmii_in* $rgmii_rx_control"] \
-add_delay

set_input_delay -clock  [get_clocks $rgmii_rx_125M_virtualclk] \
-min [expr  $data_delay_min + $tco_min - $clk_delay_max] \
[get_ports "$rgmii_in* $rgmii_rx_control"] \
-clock_fall \
-add_delay

# --------------------------------------------------------
# Take tco of External Phy and path delay difference between 
# data and clock into timing analysis consideration for 25M clock

set_input_delay -clock  [get_clocks $rgmii_rx_25M_virtualclk] \
-max [expr  $data_delay_max + $tco_max - $clk_delay_min] \
[get_ports "$rgmii_in* $rgmii_rx_control"] \
-add_delay

set_input_delay -clock  [get_clocks $rgmii_rx_25M_virtualclk] \
-max [expr  $data_delay_max + $tco_max - $clk_delay_min] \
[get_ports "$rgmii_in* $rgmii_rx_control"] \
-clock_fall \
-add_delay

set_input_delay -clock  [get_clocks $rgmii_rx_25M_virtualclk] \
-min [expr  $data_delay_min + $tco_min - $clk_delay_max] \
[get_ports "$rgmii_in* $rgmii_rx_control"] \
-add_delay

set_input_delay -clock  [get_clocks $rgmii_rx_25M_virtualclk] \
-min [expr  $data_delay_min + $tco_min - $clk_delay_max] \
[get_ports "$rgmii_in* $rgmii_rx_control"] \
-clock_fall \
-add_delay

set_input_delay -clock ad_clk_out \
-max [expr $ad_tco_max ] \
[get_ports "$ad_pcm*"] \
-add_delay

set_input_delay -clock ad_clk_out \
-min [expr $ad_tco_min ] \
[get_ports "$ad_pcm*"] \
-add_delay


#**************************************************************
# Set False Path
#**************************************************************


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

