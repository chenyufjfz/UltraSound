`timescale 1 ns / 1 ps

/*
Turn multipli cycle key_in into one cycle key_out
*/
module gen_key_signal(
		clk,
		rst,
		key_in_n,
		key_out
	);
parameter   CTR_WIDTH   =   22;

input 	    clk;	
input       rst;
input       key_in_n;
output reg  key_out;

reg		[CTR_WIDTH-1:0]		ctr;	// Reset counter


always	@(posedge clk)
begin
	if	(rst)
	begin
		key_out <= 1'b0;
		ctr <= {CTR_WIDTH{1'b1}};
	end else begin
	    if (!key_in_n)
	    begin
	        key_out <= 1'b0;
		    ctr <= 0;
	    end
		if	(ctr == {CTR_WIDTH{1'b1}})
            key_out <=  0;
		else begin
		    if (ctr + 1'b1 == {CTR_WIDTH{1'b1}})
		        key_out <= 1;
		    ctr <= ctr + 1'b1;		    
		end
	end
end

endmodule
