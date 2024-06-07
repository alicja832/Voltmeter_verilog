`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2024 01:29:10 PM
// Design Name: 
// Module Name: tb
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
module tb #(parameter depth=4096, parameter bits = 16, parameter lead_zeros = 4)();

logic clk, rst, strr, strt;
logic start;

localparam hp = 8, fclk = 100_000_000, brate = 230400, size=8, spi_size=448;
localparam nr_rec = 7;
localparam nr_trn = 10;
localparam ratio = fclk/brate - 1;
logic miso;

wire fint,finr;

top #(.depth(depth), .bits(bits),.lead_zeros(lead_zeros)) uut (.clk(clk), .rx(rx),.rst(rst), .start(start), .miso(miso), 
    .tx(tx),.ss(ss), .sclk(sclk),.leds(leds));

simple_receiver #(.fclk(fclk), .baudrate(brate), .nb(size), .deep(nr_rec)) odbiornik
    (.clk(clk), .rst(rst), .str(strr), .rx(tx), .fin(finr));

simple_transmitter #(.nb(size), .deep(nr_trn), .ratio(ratio)) nadajnik 
    (.clk(clk), .rst(rst), .str(strt), .trn(rx), .fin(fint));

spi_slave #(.bits(bits), .ndr(spi_size)) behav_slave (.cs(ss), .sclk(sclk), .miso(miso));

initial begin
#1 clk = 1'b0;

forever #1 clk=~clk;
end

initial begin
    #0 rst = 1'b0;
    #0 start = 1'b0;
    #1 rst = 1'b1;
    #4 rst = 1'b0;
    repeat(20) @(posedge clk);
    start = 1'b1;
    @(posedge clk);
    start = 1'b0;
end



initial begin
    strr = 1'b0;
    strt = 1'b0;
    @(negedge rst);
    repeat (ratio/8) @(posedge clk);
    strt = 1'b1;
    @(negedge clk);  
    strt = 1'b0;
    repeat(nr_trn) @(negedge fint);
end 

initial begin
    repeat(8) @(posedge ss);
    #2000 $finish();
end

endmodule