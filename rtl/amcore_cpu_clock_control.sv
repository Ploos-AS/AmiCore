// AmiCore M1.18 — board-independent CPU timing control boundary.
//
// The chipset/master clock remains the only clock domain here.  The CPU
// receives an enable pulse instead of a derived/gated clock.  Authentic mode
// uses a fixed divider selected by the machine profile; Turbo mode may use a
// smaller divider, but can still be stalled by the chipset/bus arbiter.
module amcore_cpu_clock_control #(
    parameter integer AUTH_DIV = 4,
    parameter integer TURBO_DIV = 1
) (
    input  logic clk,
    input  logic reset_n,
    input  logic turbo_mode,
    input  logic bus_available,
    output logic cpu_enable,
    output logic authentic_mode
);
    localparam integer MAX_DIV = (AUTH_DIV > TURBO_DIV) ? AUTH_DIV : TURBO_DIV;
    localparam integer COUNT_W = (MAX_DIV <= 1) ? 1 : $clog2(MAX_DIV);

    logic [COUNT_W-1:0] count;
    integer selected_div;

    assign authentic_mode = !turbo_mode;

    always_comb begin
        selected_div = turbo_mode ? TURBO_DIV : AUTH_DIV;
        if (selected_div < 1)
            selected_div = 1;
    end

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            count      <= '0;
            cpu_enable <= 1'b0;
        end else begin
            cpu_enable <= 1'b0;

            // A denied bus slot freezes the CPU cadence.  This is important
            // for later Authentic DMA/contention timing: acceleration must not
            // bypass chipset ownership of the shared bus.
            if (bus_available) begin
                if (selected_div == 1 || count == selected_div - 1) begin
                    count      <= '0;
                    cpu_enable <= 1'b1;
                end else begin
                    count <= count + 1'b1;
                end
            end
        end
    end

`ifndef SYNTHESIS
    initial begin
        if (AUTH_DIV < 1)
            $fatal(1, "AUTH_DIV must be >= 1");
        if (TURBO_DIV < 1)
            $fatal(1, "TURBO_DIV must be >= 1");
    end
`endif
endmodule
