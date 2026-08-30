`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2026 01:12:16 AM
// Design Name: 
// Module Name: DISPLAY
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////






module display_mux(

    input clk,
    input [7:0] data,

    output reg [3:0] an,
    output [6:0] seg

);

reg [15:0] refresh_counter;
reg refresh;
reg [3:0] digit;

always @(posedge clk)
begin
    refresh_counter <= refresh_counter + 1;

    refresh <= refresh_counter[15];
end

always @(*)
begin

    case(refresh)

        1'b0:
        begin
            an = 4'b1110;
            digit = data[3:0];
        end

        1'b1:
        begin
            an = 4'b1101;
            digit = data[7:4];
        end

    endcase

end

hex_to_7seg h1(

    .hex(digit),
    .seg(seg)

);

endmodule
