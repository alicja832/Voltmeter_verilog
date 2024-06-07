`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2024 01:01:12 PM
// Design Name: 
// Module Name: spi_master
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

module spi_master #(parameter bits = 16, lead_zeros = 4) (input clk, rst, en, miso, output ss, sclk, 
    output fin, output reg [bits-lead_zeros-1:0] data_rec);
    
//Parametry czasu trwania:
//m - czas jednego bitu (w połowie zbocze opadające sclk)
//d - opóźnienia na początku
//Parametry obliczane:
//bm - rozmiar licznika czasu
//bdcnt - rozmiar licznika bitów
localparam m = 5, d = 2, bm = $clog2(m), bdcnt = $clog2(bits);

//kodowanie stanów
typedef enum {idle, progr, start, done} e_st;
e_st st, nst;

logic [bits-1:0] shr; //rejestr przesuwny
logic [bm-1:0] cnt; //licznik czasu trwania stanów
logic [bdcnt:0] dcnt; //licznik bitów transmitowanych
logic tmp, tm, cnten;

//rejestr stanu
always @(posedge clk, posedge rst)
    if(rst)
        st <= idle;
    else
        st <= nst;
//logika automatu
always @* begin
    nst = idle;
    case(st)
        idle: 
            nst = en? start:idle;
        start: 
            nst = (cnt == d) ? progr:start;
        progr: 
            nst = (dcnt == {(bdcnt+1){1'd0}}) ? done:progr;
        done: 
            nst = idle;
endcase
end

//licznik czasu trwania stanów
//i poziomów zegara transmisji
always @(posedge clk, posedge rst)
if(rst)
    cnt <= {bm{1'b0}};
else if(cnten)
if(cnt == m | dcnt == {(bdcnt+1){1'd0}})
    cnt <= {bm{1'b0}};
else
    cnt <= cnt + 1'b1;
    
//logika sygnałów wyjściowych
assign fin = (st == done);
assign cnten = (st != idle);
//chip select
assign ss = ((st == start) | (st == progr) | (st == done))?1'b0:1'b1;
//zegar transmisji
assign sclk =((st != progr)|((st == progr) & (cnt < (m/2 + 1))))?1'b1:1'b0;

//generator zezwolenie dla rejestru przesuwnego
//detektor zbocza opadającego zegara transmisji
always @(posedge clk, posedge rst)
if(rst)
    tmp <= 1'b0;
else
    tmp <= sclk;
assign spi_en = ~sclk & tmp;
//licznik bitów
always @(posedge clk, posedge rst)
    if(rst)
        dcnt <= bits;
    else if(spi_en)
        dcnt <= dcnt - 1'b1;
    else
        if(en & dcnt == {(bdcnt+1){1'd0}})
            dcnt <= bits;
            
//rejestr przesuwny z wejściem miso 
always @(posedge clk, posedge rst)
    if(rst)
        shr <= {bits{1'b0}};
    else if(en)
        shr <= {bits{1'b0}};
    else if(spi_en)
        shr <= {shr[bits-2:0],miso};

//generator zezwolenia zapisu na wyjście
always @(posedge clk, posedge rst)
if(rst)
    tm <= 1'b0;
else
    tm <= ss;
assign en_out = ss & ~tm;

//rejestr wyjściowy
always @(posedge clk, posedge rst)    
    if(rst)
        data_rec <= {bits{1'b0}};
    else if(en_out)
        data_rec <= shr[11:0];

endmodule