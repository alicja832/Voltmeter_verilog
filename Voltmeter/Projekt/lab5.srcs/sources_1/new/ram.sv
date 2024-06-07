`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2024 02:25:24 PM
// Design Name: 
// Module Name: ram
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


module ram#(parameter depth=8*4096, nba = $clog2(depth),bits = 16,lead_zeros=4)(
    input clk, 
    output logic [7:0] data_out,
    input [bits-lead_zeros+2:0] mem_adr, input rdi);


logic [7:0] mem [1:depth];

initial $readmemh("init_mem.mem",mem);

always @(posedge clk) 
        if (rdi)begin     
                data_out <= mem[mem_adr];
            end


endmodule

