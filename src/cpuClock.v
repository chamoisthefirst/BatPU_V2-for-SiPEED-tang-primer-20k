// Clock-divided counter
//
// Inputs:  
//      clk         - 12 MHz clock
//      rst_btn     - pushbutton (RESET)
//      
// Outputs:
//      led[3:0]    - LEDs (count from 0x0 to 0xf)
//
// LEDs will display a binary number that increments by one each second.
//
// Date: October 26, 2021
// Author: Shawn Hymel
// License: 0BSD

// Count up each second
module clock (

    // Inputs
    input               clk,
    
    // Outputs
    output  reg         out
);

    wire rst;
    reg div_clk;
    reg [31:0] count;
    localparam [31:0] max_count = 600000 - 1; // max_count = 6000000 - 1; for one second clk


    // Count up on (divided) clock rising edge or reset on button push
    always @ (posedge div_clk) begin
        out <= !out;
    end
    
    // Clock divider
    always @ (posedge clk) begin
        if (count == max_count) begin
            count <= 32'b0;
            div_clk <= ~div_clk;
        end else begin
            count <= count + 1;
        end
    end
    
endmodule