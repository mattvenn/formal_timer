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
    // register for knowing if we have just started
    reg f_past_valid = 0;
    // start in reset
    initial assume(reset);
    always @(posedge clk) begin
        
        // assume timer won't get loaded with a 0
        assume(cycles > 0);

        // update past_valid reg so we know it's safe to use $past()
        f_past_valid <= 1;

        // cover the counter getting loaded and starting to count
        _busy_: cover(busy && !reset);

        // cover timer finishing
        if(f_past_valid && !$past(reset))
            _finish_: cover($past(busy) && busy == 0);

        // busy
        if(counter)
            _busy_prove_: assert(busy);

        // load works
        if(f_past_valid)
            if($past(load) && !$past(reset))
                _load_prove_: assert(counter == $past(cycles));

        // counts down
        if(f_past_valid)
            if(!$past(load) && busy)
                _counting_prove_: assert(counter == $past(counter) - 1);
    end
    `endif
    
endmodule
