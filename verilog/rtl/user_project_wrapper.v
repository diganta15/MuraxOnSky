// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
) (
`ifdef USE_POWER_PINS
    inout vdda1,    // User area 1 3.3V supply
    inout vdda2,    // User area 2 3.3V supply
    inout vssa1,    // User area 1 analog ground
    inout vssa2,    // User area 2 analog ground
    inout vccd1,    // User area 1 1.8V supply
    inout vccd2,    // User area 2 1.8v supply
    inout vssd1,    // User area 1 digital ground
    inout vssd2,    // User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

    /*--------------------------------------*/
    /* Internal Signals                     */
    /*--------------------------------------*/
    wire [31:0] murax_gpio_out;
    wire [31:0] murax_gpio_we;

/*--------------------------------------*/
    /* VexRiscv (Murax) Instantiation       */
    /*--------------------------------------*/
    Murax murax_cpu (
`ifdef USE_POWER_PINS
        .vccd1(vccd1), // Connect 1.8V
        .vssd1(vssd1), // Connect Ground
`endif
        .io_mainClk      (wb_clk_i),
        .io_asyncReset   (wb_rst_i),

        .io_uart_txd     (io_out[9]),
        .io_uart_rxd     (io_in[8]),

        .io_jtag_tms     (io_in[10]),
        .io_jtag_tdi     (io_in[11]),
        .io_jtag_tdo     (io_out[12]),
        .io_jtag_tck     (io_in[13]),

        .io_gpioA_read   ({24'b0, io_in[21:14]}), 
        .io_gpioA_write  (murax_gpio_out),
        .io_gpioA_writeEnable (murax_gpio_we)
    );

    /*--------------------------------------*/
    /* Output Enable Bar (OEB) Logic        */
    /*--------------------------------------*/
    // (Keep your UART and JTAG assignments the same here)
    assign io_oeb[9]  = 1'b0; 
    assign io_oeb[8]  = 1'b1; 
    assign io_oeb[12] = 1'b0; 
    assign io_oeb[10] = 1'b1; 
    assign io_oeb[11] = 1'b1; 
    assign io_oeb[13] = 1'b1; 
    // Tie off the output paths of our input pins to prevent floating wires
    assign io_out[8]  = 1'b0; // UART RX
    assign io_out[10] = 1'b0; // JTAG TMS
    assign io_out[11] = 1'b0; // JTAG TDI
    assign io_out[13] = 1'b0; // JTAG TCK

    // Route only the lower 8 bits of the GPIO wires to the physical pins
    assign io_out[21:14] = murax_gpio_out[7:0];
    assign io_oeb[21:14] = ~murax_gpio_we[7:0];


    /*--------------------------------------*/
    /* Tie-Offs for Unused Peripherals      */
    /*--------------------------------------*/
    
    // Unused Lower IOs (0 to 7) - Set as inputs, drive outputs low
    assign io_out[7:0] = 8'b0;
    assign io_oeb[7:0] = 8'hFF;
    
    // Unused Upper IOs (22 to 37) - Set as inputs, drive outputs low
    assign io_out[37:22] = 16'b0;
    assign io_oeb[37:22] = 16'hFFFF;

    // Unused Wishbone Interface
    assign wbs_ack_o = 1'b0;
    assign wbs_dat_o = 32'b0;

    // Unused Logic Analyzer
    assign la_data_out = 128'b0;

    // Unused Interrupts
    assign user_irq = 3'b0;

endmodule   // user_project_wrapper

`default_nettype wire