`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/10/04 16:43:30
// Design Name: 
// Module Name: extract_4bytes
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


module extract_4bytes #(
    parameter DATA_WIDTH = 1024
)(
    input  wire [DATA_WIDTH-1:0] data,
    input  wire [$clog2(DATA_WIDTH/8)-1:0] pos,      // 0 ~ 60
    output reg  [31:0]           word_out
    );
    
    always @(*) begin
        word_out[31:0]   = data[8*pos +: 32];
    end    
endmodule