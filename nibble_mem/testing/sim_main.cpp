#include <iostream>
#include <string>
#include <cstdint>
#include <sstream>

#include "Vnibble_mem.h"
#include "verilated.h"

static void tick(Vnibble_mem* top) {
    // One full clock cycle: clk 0 -> 1 -> 0
    top->clk = 0; top->eval();
    top->clk = 1; top->eval();
    top->clk = 0; top->eval();
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    auto* top = new Vnibble_mem;

    // Start in reset (active low)
    top->rst_n = 0;
    top->din   = 0;
    top->store = 0;
    top->next  = 0;
    top->prev  = 0;

    // Apply a couple ticks in reset
    tick(top);
    tick(top);

    // Release reset
    top->rst_n = 1;
    tick(top);

    // Protocol:
    // Each input line: DIN_HEX STORE NEXT PREV RST
    // Example: "A 1 0 0 0"  => din=0xA, store pulse
    //
    // Output line each step:
    // "ADDR_HEX DOUT_HEX"
    //
    // One input line = one simulated cycle, pulses last one cycle.

    std::string line;
    while (std::getline(std::cin, line)) {
        if (line == "quit" || line == "exit") break;

        std::istringstream iss(line);

        unsigned din_hex = 0;
        int store = 0, next = 0, prev = 0, rst = 0;

        if (!(iss >> std::hex >> din_hex >> std::dec >> store >> next >> prev >> rst)) {
            // Bad line: respond with current state anyway
            std::cout << std::hex
            << (unsigned)top->addr << " "
            << (unsigned)top->dout
            << std::dec << "\n" << std::flush;
            continue;
        }

        // Apply inputs
        if (rst) top->rst_n = 0; else top->rst_n = 1;

        top->din   = (din_hex & 0xF);
        top->store = store ? 1 : 0;
        top->next  = next  ? 1 : 0;
        top->prev  = prev  ? 1 : 0;

        // Tick once (pulses live for this cycle)
        tick(top);

        // Clear pulses (so they don't “stick” if GUI forgets)
        top->store = 0;
        top->next  = 0;
        top->prev  = 0;

        // Respond with current state
        std::cout << std::hex
        << (unsigned)top->addr << " "
        << (unsigned)top->dout
        << std::dec << "\n" << std::flush;
    }

    delete top;
    return 0;
}
