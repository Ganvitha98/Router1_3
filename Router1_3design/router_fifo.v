`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2024 12:22:25
// Design Name: 
// Module Name: router_fifo
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




/*module fifo ( input clock ,resetn ,write_enb ,read_enb ,soft_reset ,lfd_state ,input [7:0]data_in , output empty ,full,output reg [7:0] data_out );
integer i;
reg [8:0] mem [15:0] ;
reg [4:0]wr_pt ;
reg[4:0] rd_pt;
reg [6:0] count ;
reg lfd_state_s ;
always @(posedge clock)
begin
if(!resetn)
lfd_state_s <=0;
else
lfd_state_s <=lfd_state ;
end
// writing operation
always @(posedge clock)
begin
if (!resetn)
begin
for (i=0;i<16;i=i+1)
mem[i]<=0;
end
else if ( soft_reset ==1 )
begin
for(i=0 ;i<16;i=i+1)
mem [i]<=0;
end
else
begin
if (write_enb ==1 && full==0)
{ mem[wr_pt[3:0]][8],mem [wr_pt[3:0]][7:0]} <= {lfd_state_s, data_in} ;
end
end
//read operation
always @(posedge clock)
begin
if(!resetn)
data_out <=0;
else if (soft_reset)
data_out <=8'bz;
else
begin
if(count==0)
data_out <=8'bz;
if (read_enb ==1 && empty ==0)
data_out <= {mem[rd_pt[3:0]]};
end
end
//genearting write and read pointers
always @(posedge clock)
begin
if (!resetn)
begin
wr_pt <=0;
rd_pt <=0;
end
else
begin
if (write_enb ==1 && full==0)
wr_pt <= wr_pt +1'b1;
if (read_enb ==1 && empty==0)
rd_pt <= rd_pt +1'b1 ;
end
end
// counter logic
always @(posedge clock)
begin
if(resetn==0)
count<=0;
else if(soft_reset==1)
count <=0 ;
else if(read_enb ==1 && empty ==0)
begin
if (mem[rd_pt[3:0]][8]==1'b1)
count <= mem[rd_pt[3:0]][7:2]+1'b1 ;
else if (count !==0)
count <= count -1'b1 ;
end
end
//full and empty logic
assign full = ({wr_pt[4],wr_pt[3:0]} == {~rd_pt[4],rd_pt[3:0]})? 1'b1:1'b0;
assign empty = (wr_pt == rd_pt) ? 1'b1 :1'b0;
endmodule*/
module fifo_router(clk,rst,soft_rst,lfd_state,we,re,empty,full,din,dout);
parameter width=9,depth=16,addr=5;
input clk,rst,we,re,soft_rst,lfd_state;
input[width-2:0]din;
output full,empty;
reg lfd_state_s;
reg [6:0]fifo_count;
output reg[width-2:0]dout;
reg [width-1:0]mem[depth-1:0];
integer i;
reg [addr-1:0]wr_ptr,rd_ptr;

always@(posedge clk)
   begin
        if(!rst)
           lfd_state_s<=0;
        else
           lfd_state_s<=lfd_state;
   end

   always@(posedge clk)
    begin
        if(!rst)
           {wr_ptr,rd_ptr}<=0;
        else if(soft_rst)
           {wr_ptr,rd_ptr}<=0;
        else if(we && !full)
           wr_ptr<=wr_ptr+1;
        else if(re && !empty)
           rd_ptr<=rd_ptr+1;
   end
always@(posedge clk)
begin
        if(!rst)
        begin
                for(i=0;i<16;i=i+1)
                        mem[i]<=0;
                        end
                        if(soft_rst)
        begin
                for(i=0;i<16;i=i+1)
                        mem[i]<=0;
                        end
        else if(we && !full)
            mem[wr_ptr]<={lfd_state_s,din};
        end
always@(posedge clk)
begin
        if(!rst)
                fifo_count<=7'b0;
        else if(soft_rst)
                fifo_count<=7'b0;
        else if(re && !empty)
           if(mem[rd_ptr[3:0]][8]==1)
              fifo_count<=mem[rd_ptr[3:0]][7:2]+1;
        else if(fifo_count!=0)
                fifo_count <=fifo_count-1'b1;
        end

always@(posedge clk)
begin
        if(!rst)
                dout<=8'b0;
        else if(soft_rst)
                dout<=8'b0;
        else if(fifo_count==0 && dout!=0)
                dout<=8'b0;
        else if(re && !empty)
                dout<=mem[rd_ptr];
                else
                dout<=0;
end
assign full=(wr_ptr[4]!=rd_ptr[4] && wr_ptr[3:0]==rd_ptr[3:0])?1'b1:1'b0;
assign empty=(wr_ptr[4:0]==rd_ptr[4:0])?1'b1:1'b0;
endmodule



