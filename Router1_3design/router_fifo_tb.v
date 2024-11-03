`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.09.2024 12:25:39
// Design Name: 
// Module Name: router_fifo_tb
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



 module router_fifo_tb ();
reg clock ,resetn ,write_enb ,read_enb ,soft_reset ,lfd_state ;
reg [7:0]data_in ;
wire empty ,full;
wire [7:0] data_out;
integer j;
fifo_router DUT(.clk(clock),.rst(resetn),.we(write_enb),.re(read_enb),.soft_rst(soft_reset),.lfd_state(lfd_state),.din(data_in),.empty(empty),.full(full),.dout(data_out));
always
begin
#5;
clock=0;
#5;
clock=~clock;
end
task rst_dut() ;
begin
@(negedge clock)
resetn =1'b0;
@(negedge clock)
resetn =1'b1;
end
endtask
task soft_rst ();
begin
@(negedge clock)
soft_reset =1'b1;
@(negedge clock)
soft_reset =1'b0;
end
endtask
task write ();
reg [7:0]payload ,parity,header ;
reg [5:0]payload_len ;
reg [1:0] addrs ;
begin
@(negedge clock)
addrs = 2'b11;
payload_len =6'd14;
lfd_state =1'b1;
write_enb =1'b1;
header ={payload_len ,addrs};
data_in = header;
for(j=0;j<payload_len;j=j+1)
begin
@(negedge clock)
lfd_state =1'b0;
write_enb =1'b1;
payload = {$random}%256 ;
data_in =payload ;
end
@(negedge clock)
lfd_state =1'b0;
write_enb =1'b1;
parity = {$random}%256 ;
data_in = parity;
end
endtask
task read ();
begin
read_enb =1'b1;
end
endtask
initial
begin
rst_dut ;
soft_rst ;
write ;
#30;
read;
#300;
$finish;
end
initial
$monitor("clock=%b,resetn=%b,write_enb=%b,read_enb=%b,data_in=%b,lfd_state=%b,data_out=%b,full=%b,empty=%b",clock,resetn,write_enb,read_enb,data_in,lfd_state,data_out,full,empty);
endmodule
