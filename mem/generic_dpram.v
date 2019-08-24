//
// This block is a wrapper with common dual-port synchronous memory interface for different
// types FPGA RAMs. It is fully synthesizeable model for FPGAs. It can not be used for ASIC.
//
// Author:       Chen Yu
// Revision:    0.1 - Initial Release
//
`timescale 1ns / 1ps

module generic_dpram (
	address_a,
	address_b,
	clock_a,
	clock_b,
	data_a,
	data_b,
	rden_a,
	rden_b,
	wren_a,
	wren_b,
	q_a,
	q_b);

parameter adw = 16; // number of bits in a data-bus
parameter aaw = 9;  // number of bits in a address-bus
parameter bdw = 32; // number of bits in b data-bus
parameter pipeline=1;           //output register, pipeline=2
//parameter SIMULATION = 1;
localparam baw = (bdw > adw) ? aaw - $clog2(bdw/adw) : aaw + $clog2(adw/bdw);

	input	[aaw-1:0]  address_a;
	input	[baw-1:0]  address_b;
	input	  clock_a;
	input	  clock_b;
	input	[adw-1:0]  data_a;
	input	[bdw-1:0]  data_b;
    input     rden_a;
	input     rden_b;
	input	  wren_a;
	input	  wren_b;
	output	[adw-1:0]  q_a;
	output	[bdw-1:0]  q_b;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1	  clock_a;
	tri0	  wren_a;
	tri0	  wren_b;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire [adw-1:0] sub_wire0;
	wire [bdw-1:0] sub_wire1;
	wire [adw-1:0] q_a = sub_wire0[adw-1:0];
	wire [bdw-1:0] q_b = sub_wire1[bdw-1:0];

generate
if (pipeline==2)
begin
	altsyncram	altsyncram_component (
				.clock0 (clock_a),
				.wren_a (wren_a),
				.address_b (address_b),
				.clock1 (clock_b),
				.data_b (data_b),
				.wren_b (wren_b),
				.address_a (address_a),
				.data_a (data_a),
				.q_a (sub_wire0),
				.q_b (sub_wire1),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.addressstall_a (!(rden_a | wren_a)),
				.addressstall_b (!(rden_b | wren_b)),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.eccstatus (),
				.rden_a (1'b1),
				.rden_b (1'b1));
	defparam
		altsyncram_component.address_reg_b = "CLOCK1",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.indata_reg_b = "CLOCK1",
		altsyncram_component.intended_device_family = "Cyclone IV E",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 1<<aaw,
		altsyncram_component.numwords_b = 1<<baw,
		altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_a = "CLOCK0",
		altsyncram_component.outdata_reg_b = "CLOCK1",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.ram_block_type = "M9K",
		altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.widthad_a = aaw,
		altsyncram_component.widthad_b = baw,
		altsyncram_component.width_a = adw,
		altsyncram_component.width_b = bdw,
		altsyncram_component.width_byteena_a = 1,
		altsyncram_component.width_byteena_b = 1,
		altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK1";
end
else
begin
altsyncram	altsyncram_component (
				.clock0 (clock_a),
				.wren_a (wren_a),
				.address_b (address_b),
				.clock1 (clock_b),
				.data_b (data_b),
				.wren_b (wren_b),
				.address_a (address_a),
				.data_a (data_a),
				.q_a (sub_wire0),
				.q_b (sub_wire1),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.addressstall_a (!(rden_a | wren_a)),
				.addressstall_b (!(rden_b | wren_b)),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.eccstatus (),
				.rden_a (1'b1),
				.rden_b (1'b1));
	defparam
		altsyncram_component.address_reg_b = "CLOCK1",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.indata_reg_b = "CLOCK1",
		altsyncram_component.intended_device_family = "Cyclone IV E",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 1<<aaw,
		altsyncram_component.numwords_b = 1<<baw,
		altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_a = "UNREGISTERED",
		altsyncram_component.outdata_reg_b = "UNREGISTERED",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.ram_block_type = "M9K",
		altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.widthad_a = aaw,
		altsyncram_component.widthad_b = baw,
		altsyncram_component.width_a = adw,
		altsyncram_component.width_b = bdw,
		altsyncram_component.width_byteena_a = 1,
		altsyncram_component.width_byteena_b = 1,
		altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK1";
end
endgenerate
endmodule
