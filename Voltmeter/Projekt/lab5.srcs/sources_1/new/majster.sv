`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2024 02:32:24 PM
// Design Name: 
// Module Name: axi_master
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


module axi_master #(parameter nbadr=3)(
    input clk, input rst,
    output logic[3:0] awadr, output logic awvld, input awrdy,
    output [31:0] wdat, output logic wvld, input wrdy, 
    input bvld, output logic brdy,
    output logic [3:0] aradr, output logic arvld, input arrdy,
    input [7:0] rdat, input rvld, output logic rrdy,
    output logic wr, rd, input [7:0] data_out, output logic[nbadr-1:0] addr
    );
    
typedef enum {ReadStatus, WaitStatus, Write, Read, WaitRead, Command, WaitWrite, WaitResp} states;
states st, nst;

logic rec_trn;
logic cmdm;
logic [5:0] maxd;
wire rfifo_valid = ((st == WaitStatus) && rvld) ? rdat[0] : 1'b0;
wire tfifo_full = ((st == WaitStatus) && rvld) ? rdat[3] : 1'b0;
    
        
always @*
    begin
        nst = Read;
        case(st)
            ReadStatus: nst = WaitStatus;
            
            WaitStatus: if(rec_trn)
                nst = rfifo_valid ? (rvld ? Read : WaitStatus) : ReadStatus;
            else
                nst = tfifo_full ? ReadStatus : (rvld ? Write : WaitStatus);
                
            Read: nst = WaitRead;
            WaitRead: nst = rvld ? (rdat[7] ? Command : ReadStatus) : WaitRead;
            Command: nst = ReadStatus;
            Write: nst = WaitWrite;
            WaitWrite: nst = awrdy ? WaitResp : WaitWrite;
            WaitResp:  nst = bvld? ReadStatus : WaitResp;
        endcase
     end
    
always @(posedge clk, posedge rst)
    if(rst)
       st <= Read;
    else
        st <= nst;

always @(posedge clk, posedge rst)
    if(rst)
        aradr <= 4'b0;
    else if(st == ReadStatus)
        aradr <= 4'd8;
    else
        aradr <= 4'b0;
        
always @(posedge clk, posedge rst)
    if(rst)
        arvld <= 1'b0;
    else if(st == ReadStatus || st == Read)
        arvld <= 1'b1;
    else if(arrdy)
        arvld <= 1'b0;
        
always @(posedge clk, posedge rst)
    if(rst)
        rrdy <= 1'b0;
    else if(st == WaitStatus && rvld || st == WaitRead && rvld)
        rrdy <= 1'b1;
    else
        rrdy <= 1'b0;
//command decoder
always @(posedge clk, posedge rst)
    if(rst) begin
        rec_trn <=1'b1;
        cmdm <=1'b1;
        maxd <= 6'b0;
    end    
    else if(st ==Command) begin
        maxd <= rdat[5:0];
        case(rdat[7:6])
            2'b10: cmdm <= (rdat[5:0] == 6'b0) ? 1'b1 : 1'b0;
            2'b11: rec_trn <= 1'b0;
        endcase
    end
    else if((st == WaitResp && addr == maxd)) begin
        rec_trn <=1'b1;
        cmdm <=1'b1; 
    end
    
wire incar = (st == WaitRead) & (rec_trn) & ~cmdm & rvld & (addr<maxd) ;
wire incat = (st == Write) &  ~(rec_trn) & cmdm & (addr<maxd);

    
//else czeka nas rozbudowa po dodaniu stanow zwiazanych z write    
always@(posedge clk, posedge rst)
     if(rst)
        wr <= 1'b0;
     else
        wr <= incar;        

//generator adresu
always@(posedge clk)
     if(rst)
        addr <= {nbadr{1'b0}};  
     else if(incar | incat)
        addr <= addr + 1'b1;
     else if((st == WaitResp && addr == maxd) || st == Command)
        addr <= {nbadr{1'b0}}; 
        
always@(posedge clk, posedge rst)
     if(rst)
        rd <= 1'b0;
     else
        rd <= (st == Write);  


//AW
        
always @(posedge clk, posedge rst)
    if(rst)
        awadr <= 4'b0;
    else if(st == Write || st == WaitWrite)
         awadr <= 4'd4;
    else if(awrdy)
         awadr <= 4'b0;

       
always @(posedge clk, posedge rst)
    if(rst)
        awvld <= 1'b0;
    else if(st == Write)
         awvld <= 1'b1;
    else if(awrdy)
         awvld <= 1'b0;

//w
always @(posedge clk, posedge rst)
    if(rst)
       wvld <= 1'b0;
    else if(st == Write)
       wvld <= 1'b1;
    else if(wrdy)
       wvld <= 1'b0;         

assign wdat = (st == WaitWrite) ? {24'b0, data_out} : 32'b0;

always @(posedge clk, posedge rst)
    if(rst)
        brdy <= 1'b0;
    else begin
        if(st == Write)
            brdy <= 1'b1;
        if(bvld)
            brdy <= 1'b0;
end
    
endmodule