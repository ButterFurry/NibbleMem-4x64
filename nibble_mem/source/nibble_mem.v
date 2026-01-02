//     __/\\\\\_____/\\\________/\\\_________/\\\_________/\\\\\\____________________/\\\\____________/\\\\____________________________________
//      _\/\\\\\\___\/\\\_______\/\\\________\/\\\________\////\\\___________________\/\\\\\\________/\\\\\\____________________________________
//       _\/\\\/\\\__\/\\\__/\\\_\/\\\________\/\\\___________\/\\\___________________\/\\\//\\\____/\\\//\\\____________________________________
//        _\/\\\//\\\_\/\\\_\///__\/\\\________\/\\\___________\/\\\________/\\\\\\\\__\/\\\\///\\\/\\\/_\/\\\_____/\\\\\\\\_____/\\\\\__/\\\\\___
//         _\/\\\\//\\\\/\\\__/\\\_\/\\\\\\\\\__\/\\\\\\\\\_____\/\\\______/\\\/////\\\_\/\\\__\///\\\/___\/\\\___/\\\/////\\\__/\\\///\\\\\///\\\_
//          _\/\\\_\//\\\/\\\_\/\\\_\/\\\////\\\_\/\\\////\\\____\/\\\_____/\\\\\\\\\\\__\/\\\____\///_____\/\\\__/\\\\\\\\\\\__\/\\\_\//\\\__\/\\\_
//           _\/\\\__\//\\\\\\_\/\\\_\/\\\__\/\\\_\/\\\__\/\\\____\/\\\____\//\\///////___\/\\\_____________\/\\\_\//\\///////___\/\\\__\/\\\__\/\\\_
//            _\/\\\___\//\\\\\_\/\\\_\/\\\\\\\\\__\/\\\\\\\\\___/\\\\\\\\\__\//\\\\\\\\\\_\/\\\_____________\/\\\__\//\\\\\\\\\\_\/\\\__\/\\\__\/\\\_
//             _\///_____\/////__\///__\/////////___\/////////___\/////////____\//////////__\///______________\///____\//////////__\///___\///___\///__


// Licensed under the CERN-OHL-S-2.0 license

module nibble_mem (
    input  wire        clk,
    input  wire        rst_n,   // active-low reset

    input  wire [3:0]  din,

    input  wire        store,
    input  wire        next,
    input  wire        prev,

    output reg  [3:0]  dout,
    output reg  [5:0]  addr    // optional: can be left unconnected
);

    // 64 words x 4 bits
    reg [3:0] mem [0:63];

    // -----------------------------
    // 1) Synchronize async controls
    // -----------------------------
    reg store_ff1, store_ff2;
    reg next_ff1,  next_ff2;
    reg prev_ff1,  prev_ff2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            store_ff1 <= 1'b0; store_ff2 <= 1'b0;
            next_ff1  <= 1'b0; next_ff2  <= 1'b0;
            prev_ff1  <= 1'b0; prev_ff2  <= 1'b0;
        end else begin
            store_ff1 <= store; store_ff2 <= store_ff1;
            next_ff1  <= next;  next_ff2  <= next_ff1;
            prev_ff1  <= prev;  prev_ff2  <= prev_ff1;
        end
    end

    // -----------------------------
    // 2) Edge detect => 1-cycle pulses
    // -----------------------------
    reg store_d, next_d, prev_d;
    wire store_pulse = store_ff2 & ~store_d;
    wire next_pulse  = next_ff2  & ~next_d;
    wire prev_pulse  = prev_ff2  & ~prev_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            store_d <= 1'b0;
            next_d  <= 1'b0;
            prev_d  <= 1'b0;
        end else begin
            store_d <= store_ff2;
            next_d  <= next_ff2;
            prev_d  <= prev_ff2;
        end
    end

    // -----------------------------
    // 3) Main logic
    // -----------------------------
    integer i;

    // combinational "next address" (wire), no blocking assignments in sequential logic
    wire [5:0] addr_inc = addr + 6'd1;
    wire [5:0] addr_dec = addr - 6'd1;

    // Choose what addr will become after this clock edge
    wire [5:0] addr_after =
        store_pulse ? addr_inc :
        next_pulse  ? addr_inc :
        prev_pulse  ? addr_dec :
                      addr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            addr <= 6'd0;
            dout <= 4'd0;

            // deterministic startup (small enough to reset safely)
            for (i = 0; i < 64; i = i + 1)
                mem[i] <= 4'd0;

        end else begin
            // write on store
            if (store_pulse) begin
                mem[addr] <= din;
            end

            // update address
            addr <= addr_after;

            // registered readout of the selected word (post-update)
            dout <= mem[addr_after];
        end
    end

endmodule
