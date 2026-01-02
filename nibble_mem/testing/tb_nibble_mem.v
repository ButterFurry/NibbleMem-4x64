`timescale 1ns/1ps

module tb_nibble_mem;
    reg clk = 0;
    reg rst_n = 0;

    reg  [3:0] din = 0;
    reg  store = 0, next = 0, prev = 0;

    wire [3:0] dout;
    wire [5:0] addr;

    nibble_mem dut (
        .clk(clk), .rst_n(rst_n),
        .din(din), .store(store), .next(next), .prev(prev),
        .dout(dout), .addr(addr)
    );

    // 100 MHz clock (10ns period)
    always #5 clk = ~clk;

    // helper task: make a 1-clock pulse aligned to clk
    task pulse(input reg which);
        begin
            // which: 0=store,1=next,2=prev
            @(negedge clk);
            if (which == 0) store = 1;
            if (which == 1) next  = 1;
            if (which == 2) prev  = 1;
            @(negedge clk);
            store = 0; next = 0; prev = 0;
        end
    endtask

    initial begin
        $dumpfile("nibble_mem.vcd");
        $dumpvars(0, tb_nibble_mem);

        // reset
        rst_n = 0;
        repeat (3) @(negedge clk);
        rst_n = 1;

        // Write 0xA to word 0, auto-increment to 1
        din = 4'hA;
        pulse(0);

        // Write 0x3 to word 1, auto-increment to 2
        din = 4'h3;
        pulse(0);

        // Browse back one word (to 1) without writing
        pulse(2);

        // Browse back one word (to 0) without writing
        pulse(2);

        // Browse forward (to 1)
        pulse(1);

        // Write 0xF to word 1, auto-increment to 2
        din = 4'hF;
        pulse(0);

        // Let it run a few cycles so dout settles
        repeat (10) @(negedge clk);

        $display("Final addr=%0d dout=0x%0h", addr, dout);
        $finish;
    end
endmodule
