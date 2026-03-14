/**
 * Module: lif_neuron
 * Description: A digital Leaky Integrate-and-Fire (LIF) neuron.
 *
 * Parameters:
 * POTENTIAL_WIDTH - Bit-width of the membrane potential register.
 * THRESHOLD - Firing threshold.
 * LEAK_AMOUNT - Amount to "leak" (subtract) each clock cycle.
 * WEIGHT - Amount to "integrate" (add) for each input spike.
 * RESET_POTENTIAL - Potential to reset to after firing (usually 0).
 */
 
`timescale 1ns / 100ps

module lif_neuron #(
    parameter POTENTIAL_WIDTH = 16,
    parameter RESET_POTENTIAL = 0,
    parameter LEAK_SHIFT = 4
) (
    input [POTENTIAL_WIDTH-1:0] threshold,
    input [POTENTIAL_WIDTH-5:0] weight,
    input clk, // Clock
    input rst_n, // Asynchronous active-low reset
    input spike_in, // Input spike (1-bit pulse)
    output reg spike_out // Output spike (1-bit pulse)
);

    // Internal register for the neuron's membrane potential
    reg [POTENTIAL_WIDTH-1:0] membrane_potential;

    // Combinational logic to determine the next state of the potential
    wire [POTENTIAL_WIDTH-1:0] next_potential;

    wire [POTENTIAL_WIDTH-1:0] leak_value;

    // Internal flag to signal a firing event
    wire will_fire;

    // Firing condition: potential exceeds or meets the threshold
    assign will_fire = (membrane_potential >= threshold);

    // Logic for next potential state
    assign next_potential = 
        // 1. Firing condition (highest priority)
        (will_fire) ? RESET_POTENTIAL :
        
        // 2. Integration condition
        (spike_in) ? (membrane_potential + weight) : membrane_potential;
    
    assign leak_value = next_potential >> LEAK_SHIFT;

    // Sequential logic (registers)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset state
            membrane_potential <= RESET_POTENTIAL;
            spike_out <= 1'b0;
            end
         else begin
            // Update potential on every clock edge
            membrane_potential <= next_potential-leak_value;
            
            // Output spike is a single-cycle pulse
            // It becomes high *in the cycle after* the threshold is met
            spike_out <= will_fire; 
        end
    end

endmodule
