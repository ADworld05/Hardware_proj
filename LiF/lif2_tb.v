`timescale 1ns / 1ps

module lif_neuron_tb;

    // --- Parameters ---
    // These must match the parameters of your DUT
    localparam POTENTIAL_WIDTH = 16;
    localparam RESET_POTENTIAL = 0;
    localparam LEAK_SHIFT = 4; // Vm = Vm - (Vm >> 4)
    localparam CLK_PERIOD = 10; // 10ns clock period

    // --- Signals ---
    // Regs for inputs
    reg [POTENTIAL_WIDTH-1:0] threshold;
    reg [POTENTIAL_WIDTH-5:0] weight; // This is [11:0] as per your image
    reg clk;
    reg rst_n;
    reg spike_in;

    // Wire for output
    wire spike_out;

    // --- Instantiate the Device Under Test (DUT) ---
    lif_neuron #(
        .POTENTIAL_WIDTH(POTENTIAL_WIDTH),
        .RESET_POTENTIAL(RESET_POTENTIAL),
        .LEAK_SHIFT(LEAK_SHIFT)
    ) dut (
        .threshold(threshold),
        .weight(weight),
        .clk(clk),
        .rst_n(rst_n),
        .spike_in(spike_in),
        .spike_out(spike_out)
    );

    // --- Clock Generator ---
    always #((CLK_PERIOD / 2)) clk = ~clk;

    // --- Test Scenarios ---
    initial begin
        // --- 1. Initialization and Reset ---
        $display("--- 1. System Reset ---");
        clk = 0;
        rst_n = 0; // Assert reset
        spike_in = 0;
        threshold = 100; // Set a threshold
        weight = 30; // Set a weight

        // Wait for 2 clock cycles
        #(CLK_PERIOD * 2); 
        
        rst_n = 1; // De-assert reset
        $display("Time=%0t: Reset released. Vm = %0d", $time, dut.membrane_potential);
        
        #(CLK_PERIOD);

        // --- 2. Test Integration and Leak ---
        $display("\n--- 2. Test: Integrate and Leak ---");
        
        // Send one spike
        spike_in = 1;
        #(CLK_PERIOD); 
        // Vm should be: (0+30) - (30>>4) = 30 - 1 = 29
        $display("Time=%0t: Spike 1. Vm = %0d", $time, dut.membrane_potential);

        // Let it leak
        spike_in = 0;
        #(CLK_PERIOD);
        // Vm should be: 29 - (29>>4) = 29 - 1 = 28
        $display("Time=%0t: Leak. Vm = %0d", $time, dut.membrane_potential);

        #(CLK_PERIOD);
        // Vm should be: 28 - (28>>4) = 28 - 1 = 27
        $display("Time=%0t: Leak. Vm = %0d", $time, dut.membrane_potential);

        // Send another spike
        spike_in = 1;
        #(CLK_PERIOD);
        // Vm should be: (27+30) - (57>>4) = 57 - 3 = 54
        $display("Time=%0t: Spike 2. Vm = %0d", $time, dut.membrane_potential);
        spike_in = 0;

        // --- 3. Test: Integrate to Fire ---
        $display("\n--- 3. Test: Integrate to Fire (Threshold=100) ---");
        // Vm is currently 54
        
        #(CLK_PERIOD);
        // Vm should be: 54 - (54>>4) = 54 - 3 = 51
        $display("Time=%0t: Leak. Vm = %0d", $time, dut.membrane_potential);
        
        spike_in = 1;
        #(CLK_PERIOD);
        // Vm should be: (51+30) - (81>>4) = 81 - 5 = 76
        $display("Time=%0t: Spike 3. Vm = %0d", $time, dut.membrane_potential);
        spike_in = 0;

        #(CLK_PERIOD);
        // Vm should be: 76 - (76>>4) = 76 - 4 = 72
        $display("Time=%0t: Leak. Vm = %0d", $time, dut.membrane_potential);

        spike_in = 1;
        #(CLK_PERIOD);
        // Vm should be: (72+30) - (102>>4) = 102 - 6 = 96
        $display("Time=%0t: Spike 4. Vm = %0d", $time, dut.membrane_potential);
        spike_in = 0;
        
        #(CLK_PERIOD);
        // Vm should be: 96 - (96>>4) = 96 - 6 = 90
        $display("Time=%0t: Leak. Vm = %0d", $time, dut.membrane_potential);

        spike_in = 1;
        #(CLK_PERIOD);
        // Vm should be: (90+30) - (120>>4) = 120 - 7 = 113
        $display("Time=%0t: Spike 5. Vm = %0d. (Potential > Threshold)", $time, dut.membrane_potential);
        spike_in = 0;


        // --- 4. Test: Post-Fire Reset ---
        $display("\n--- 4. Test: Neuron Fires and Resets ---");
        // On this next clock edge, spike_out should be 1
        // and membrane_potential should reset to 0.
        #(CLK_PERIOD);
        $display("Time=%0t: FIRE! spike_out = %b. Vm resets to %0d", 
                  $time, spike_out, dut.membrane_potential);

        #(CLK_PERIOD);
        $display("Time=%0t: spike_out goes low. Vm = %0d", 
                  $time, spike_out, dut.membrane_potential);

        $display("\n--- Testbench Finished ---");
        $finish; // End the simulation
    end

    // --- Monitor ---
    // This will print the values every time a signal changes
    initial begin
        $monitor("Time=%0t | rst_n=%b clk=%b spike_in=%b | Vm=%0d | spike_out=%b",
                 $time, rst_n, clk, spike_in, dut.membrane_potential, spike_out);
    end

endmodule


