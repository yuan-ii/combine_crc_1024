`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/08/22 09:40:25
// Design Name: 
// Module Name: lfsr_top
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


module gen_rom_top(
    input [1023:0] data_in,
    input [127:0]data_valid,
    input data_last,
    output wire [63:0] crc_out,
    input rst,
    input clk
    );
    
    reg [31:0] crc_state;
    reg [31:0] fcs_reg;
    wire [31:0] temp_crc;
    
    reg  [31:0] crc_state;   // 内部仍可用数组
    wire [31:0] temp_crc;   // 内部仍可用数组

    reg  [31:0] crc_out_reg;      // 扁平化输出寄存器

    assign crc_out_flat = crc_out_reg;
      


        gen_rom #(
            .LFSR_WIDTH       (32),
            .LFSR_POLY        (32'h4c11db7),
            .LFSR_CONFIG      ("GALOIS"),
            .LFSR_FEED_FORWARD(0),
            .REVERSE          (1),
            .DATA_WIDTH       (1024),
            .STYLE            ("AUTO")
        )
        eth_crc_inst (
            .data_in  (data_in),
            .state_in (crc_state),
            .data_out (),
            .state_out(temp_crc)
        );

        always @(posedge clk) begin
            if (rst) begin
                crc_state <= 32'd0;
                crc_out_reg <= 32'd0;
            end else begin
                if (data_valid) begin
                    crc_state <= temp_crc;

                    if (data_last) begin
                        crc_state <= 32'd0;
                        crc_out_reg <= ~temp_crc;
                    end
                end
            end
        end

endmodule
