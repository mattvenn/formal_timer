`default_nettype none
module timer(
    input clk,
    input reset,
    input load,
    input [15:0] cycles,
    output busy
    );

    reg [15:0] counter;

    always @(posedge clk) begin
        if(reset)
            counter <= 0;
        else if (load)
            counter <= cycles;
        else if (counter > 0)
            counter <= counter - 1'b1;
    end

    assign busy = counter > 0;

    `ifdef FORMAL
    reg f_past_valid = 0;
    initial assume(reset);
    always @(posedge clk) begin
        
        assume(cycles > 0);

        f_past_valid <= 1;

        // cover the counter getting loaded and starting to count
        if(!reset)
            loaded: cover(busy);

        // cover finishing
        if(f_past_valid && !$past(reset))
            finish: cover($past(busy) && !busy);

        // load works
        if(f_past_valid)
            if($past(load) && !$past(reset))
                assert(counter == $past(cycles));

        // counts down
        if(f_past_valid)
            if($past(busy) && !$past(reset) && !$past(load))
                assert(counter == $past(counter) - 1);

        // busy
        if(counter)
            assert(busy);
    end
    `endif
    
endmodule
