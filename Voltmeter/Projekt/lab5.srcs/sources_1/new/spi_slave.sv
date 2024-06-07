`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/13/2024 04:47:52 PM
// Design Name: 
// Module Name: spi_slave
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

module spi_slave #(parameter bits = 16, lead_zeros = 4, ndr = 4)
(input cs, sclk, output miso);

logic [bits-1:0] shr;
//logic [bits-1:0] data_in [1:ndr];
//int i = 0;
logic [bits-lead_zeros-1:0] data_out [1:ndr];
int j = 1;

initial $readmemh("mmm.mem", data_out);
//rejestr przesuwny
assign #11 miso = shr[bits-1];

always @(negedge sclk)
   shr <= {shr[bits-2:0], 1'b0};
    
always @(negedge cs)
    shr <= {{lead_zeros{1'b0}}, data_out[j++]};

//always @(posedge cs)
//    data_in[i++] <= shr; //zachowanie słowa odebranego

endmodule