`timescale 1 ns / 1 ps

module wrapper_tb;

    // ---------------------------------------------------
    // 1. Signals & Clocks
    // ---------------------------------------------------
    reg  clock;
    reg  reset;
    
    // Caravel IO Arrays
    reg  [37:0] io_in_sim;
    wire [37:0] io_out;
    wire [37:0] io_oeb;

    // ---------------------------------------------------
    // 2. Unit Under Test (UUT)
    // ---------------------------------------------------
    user_project_wrapper uut (
        .wb_clk_i (clock),
        .wb_rst_i (reset),
        
        // Wishbone slave tied off for this test
        .wbs_stb_i(1'b0),
        .wbs_cyc_i(1'b0),
        .wbs_we_i (1'b0),
        .wbs_sel_i(4'b0),
        .wbs_dat_i(32'b0),
        .wbs_adr_i(32'b0),
        
        .io_in  (io_in_sim),
        .io_out (io_out),
        .io_oeb (io_oeb)
    );

    // ---------------------------------------------------
    // 3. Clock Generation (40 MHz target)
    // ---------------------------------------------------
    initial begin
        clock = 0;
        forever #12.5 clock = ~clock; 
    end

    // ---------------------------------------------------
    // 4. Test Sequence & VCD Dumping
    // ---------------------------------------------------
    initial begin
        // Setup waveform dump for GTKWave
        $dumpfile("wrapper_tb.vcd");
        $dumpvars(0, wrapper_tb);

        // Initialize inputs
        io_in_sim = 38'b0;
        reset = 1;

        $display("----------------------------------------");
        $display("Starting Murax Wrapper Simulation...");
        $display("----------------------------------------");

        // Hold reset for 100ns
        #100;
        reset = 0;
        $display("[%0t] Reset released. Murax booting...", $time);

        // Let the CPU run for a while. 
        // Even without a C payload loaded into its RAM, we should see 
        // the program counter increment internally and the OEB lines assert correctly.
        #5000;

        // Check the OEB logic we wrote
        if (io_oeb[9] === 1'b0) 
            $display("[%0t] PASS: UART TX (Pin 9) is configured as an output.", $time);
        else 
            $error("[%0t] FAIL: UART TX (Pin 9) OEB is wrong!", $time);

        if (io_oeb[8] === 1'b1) 
            $display("[%0t] PASS: UART RX (Pin 8) is configured as an input.", $time);
        else 
            $error("[%0t] FAIL: UART RX (Pin 8) OEB is wrong!", $time);

        $display("----------------------------------------");
        $display("Simulation Complete.");
        $display("----------------------------------------");
        $finish;
    end

endmodule