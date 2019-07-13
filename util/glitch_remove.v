`timescale 1ns / 1ps

module glitch_remove(
    clk,
    rst,
    glitch_in,
    glitch_free_out
);

parameter   CTR_WIDTH   =   20;

    input           clk;
    input           rst;
    input           glitch_in;
    output          glitch_free_out;
    
    reg	[CTR_WIDTH-1:0] ctr;	// glitch free counter
    
    always	@(posedge clk)
    begin
        if (rst || !glitch_in)
            ctr <= #1 0;
        else
            if	(ctr != {CTR_WIDTH{1'b1}})
                ctr <= #1 ctr + 1;
    end
    
    assign glitch_free_out = glitch_in && (ctr == {CTR_WIDTH{1'b1}});
endmodule