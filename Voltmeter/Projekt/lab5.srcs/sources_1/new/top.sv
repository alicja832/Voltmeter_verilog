`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2024 02:22:07 PM
// Design Name: 
// Module Name: top
//////////////////////////////////////////////////////////////////////////////////


module top#(parameter depth=8*4096, parameter bits = 16, parameter lead_zeros = 4)(input clk, rst, rx,start, miso, output tx,ss, sclk,output [7:0] leds);

wire [3 : 0] s_axi_awaddr;
wire [31 : 0] s_axi_wdata;
wire [3: 0] s_axi_wstrb = 4'b1111;
//wire [1 : 0] s_axi_bresp;
wire [3 : 0] s_axi_araddr;
wire [7 : 0] s_axi_rdata;
wire [23:0] unused = {24'bZ};
wire [2:0] addr;
wire [7:0] dout;
localparam nba = 3; //$clog2(depth); 



axi_slave_uart your_instance_name (
  .s_axi_aclk(clk),        // input wire s_axi_aclk
  .s_axi_aresetn(~rst),  // input wire s_axi_aresetn
  .interrupt(),          // output wire interrupt
  .s_axi_awaddr(s_axi_awaddr),    // input wire [3 : 0] s_axi_awaddr
  .s_axi_awvalid(s_axi_awvalid),  // input wire s_axi_awvalid
  .s_axi_awready(s_axi_awready),  // output wire s_axi_awready
  
  .s_axi_wdata(s_axi_wdata),      // input wire [31 : 0] s_axi_wdata
  .s_axi_wstrb(s_axi_wstrb),      // input wire [3 : 0] s_axi_wstrb
  .s_axi_wvalid(s_axi_wvalid),    // input wire s_axi_wvalid
  .s_axi_wready(s_axi_wready),    // output wire s_axi_wready
  
  .s_axi_bresp(),      // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid(s_axi_bvalid),    // output wire s_axi_bvalid
  .s_axi_bready(s_axi_bready),    // input wire s_axi_bready
  
  .s_axi_araddr(s_axi_araddr),    // input wire [3 : 0] s_axi_araddr
  .s_axi_arvalid(s_axi_arvalid),  // input wire s_axi_arvalid
  .s_axi_arready(s_axi_arready),  // output wire s_axi_arready
  
  .s_axi_rdata({unused,s_axi_rdata}),      // output wire [31 : 0] s_axi_rdata
  .s_axi_rresp(),      // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid(s_axi_rvalid),    // output wire s_axi_rvalid
  .s_axi_rready(s_axi_rready),    // input wire s_axi_rready
  
  .rx(rx),                        // input wire rx
  .tx(tx)                        // output wire tx
);


axi_master  #(.nbadr(nba)) majster(
    .clk(clk),
    .rst(rst),
    .awadr(s_axi_awaddr),
    .awvld(s_axi_awvalid),
    .awrdy(s_axi_awready),
    .wdat(s_axi_wdata),
    .wvld(s_axi_wvalid),
    .wrdy(s_axi_wready),
    .bvld(s_axi_bvalid),
    .brdy(s_axi_bready),
    .aradr(s_axi_araddr),
    .arvld(s_axi_arvalid),
    .arrdy(s_axi_arready),
    .rdat(s_axi_rdata),
    .rvld(s_axi_rvalid),
    .rrdy(s_axi_rready),
    .wr(wr),
    .rd(rd),
    .data_out(dout),
    .addr(addr)
    );
 wire [bits-lead_zeros-1:0] data;   


typedef enum {idle, enable, operation} stany;
stany st, nst;

spi_master #(.bits(bits), .lead_zeros(lead_zeros)) SPI
   (.clk(clk), .rst(rst), .en(en), .fin(fin), .miso(miso), .ss(ss), .sclk(sclk), .data_rec(data));

ram#(.depth(depth),.lead_zeros(lead_zeros), .bits(bits)) ramm(
   .clk(clk), 
     .data_out(dout),
    .mem_adr({data, addr}), .rdi(rd));
    
assign leds = data[11:4];

always @(posedge clk, posedge rst)
    if(rst)
        st <= idle;
    else
        st <= nst;
        
always @* begin
    nst = idle;
    case(st)
        idle: nst = start ? enable : idle ;
        enable: nst = operation;
        operation: nst = fin ? enable : operation;
    endcase
end

assign en = (st == enable);

endmodule
