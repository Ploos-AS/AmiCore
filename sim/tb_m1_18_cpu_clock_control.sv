`timescale 1ns/1ps
module tb_m1_18_cpu_clock_control;
    logic clk = 0;
    logic reset_n = 0;
    logic turbo_mode = 0;
    logic bus_available = 1;
    logic cpu_enable;
    logic authentic_mode;
    integer cycles;
    integer pulses;

    amcore_cpu_clock_control #(.AUTH_DIV(4), .TURBO_DIV(1)) dut (
        .clk(clk), .reset_n(reset_n), .turbo_mode(turbo_mode),
        .bus_available(bus_available), .cpu_enable(cpu_enable),
        .authentic_mode(authentic_mode)
    );

    always #5 clk = ~clk;

    task automatic run_cycles(input integer n);
        integer j;
        begin
            pulses = 0;
            for (j = 0; j < n; j = j + 1) begin
                @(posedge clk); #1;
                if (cpu_enable) pulses = pulses + 1;
            end
        end
    endtask

    initial begin
        repeat (2) @(posedge clk);
        reset_n = 1;

        run_cycles(8);
        if (!authentic_mode || pulses != 2)
            $fatal(1, "Authentic cadence failed: pulses=%0d", pulses);

        // Reset before changing policy so qualification is deterministic and
        // does not depend on a partial divider period.
        reset_n = 0; @(posedge clk); reset_n = 1;
        turbo_mode = 1;
        run_cycles(8);
        if (authentic_mode || pulses != 8)
            $fatal(1, "Turbo cadence failed: pulses=%0d", pulses);

        // Shared-bus denial must stop execution even in Turbo mode.
        bus_available = 0;
        run_cycles(5);
        if (pulses != 0)
            $fatal(1, "CPU advanced while bus unavailable");

        bus_available = 1;
        run_cycles(3);
        if (pulses != 3)
            $fatal(1, "CPU did not resume after bus grant");

        $display("M1.18 PASS: Authentic/Turbo CPU timing boundary qualified");
        $finish;
    end

    initial begin
        #5000;
        $fatal(1, "M1.18 watchdog timeout");
    end
endmodule
