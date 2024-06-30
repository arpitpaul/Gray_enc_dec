`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2024 11:08:54
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
class transaction;
randc bit[7:0] din;
randc bit sel;
bit [7:0] dout;
endclass


interface gray_enc_intf();
logic [7:0] din;
logic sel;
logic [7:0] dout;
endinterface



class generator;

integer i;
event done;
mailbox mbx;
transaction t;


function new(mailbox mbx);

this.mbx=mbx;

endfunction


task run();

t=new();

for(i=0;i<30;i++)
begin
t.randomize();
mbx.put(t);
@done;
#10;
end
endtask
endclass


class driver;
mailbox mbx;
event done;
virtual gray_enc_intf vif;
transaction t;
function new(mailbox mbx);
this.mbx=mbx;
endfunction



task run();
mbx.get(t);
forever begin
vif.din = t.din;
vif.sel = t.sel;

->done;
#10;
end
endtask
endclass


class monitor;
mailbox mbx;
transaction t;
virtual gray_enc_intf vif;


function new(mailbox mbx);
this.mbx=mbx;
endfunction

task run();
forever begin
t=new();

t.din=vif.din;
t.sel=vif.sel;
t.dout=vif.dout;

mbx.put(t);

#10;
end
endtask
endclass



class scoreboard;
mailbox mbx;
bit [7:0] temp;
integer i;
transaction t;

function new(mailbox mbx);
this.mbx=mbx;
endfunction


task run();
forever begin
mbx.get(t);

if(t.sel==1'b0)
 begin
    temp[7]=t.din[7];
    for(i=6;i>=0;i--)
      begin
         temp[i]=t.din[i]+t.din[i+1];
      end
      
      if(temp==t.dout)
       $display("[SCO]:Testcase passed");
     
     
     else
       $display("[SCO]:Testcase failed");
 
 end
     
     
      else if(t.sel==1'b1)
      begin
        temp[7]= t.din[7];
        
        for(i=6;i>=0; i--)
        begin
          temp[i]=t.din[i]+temp[i+1];
        end
        
      if(temp==t.dout)
       $display("[SCO]:Testcase passed");
     
     
     else
       $display("[SCO]:Testcase failed");
      end
      
      else
        $display("[SCO]:Testcase failed");
      
end
endtask
endclass



class environment;
generator gen;
driver drv;
monitor mon;
scoreboard sco;
mailbox gdmbx, msmbx;
virtual gray_enc_intf vif;
event gddone;



function new(mailbox gdmbx, mailbox msmbx);
this.gdmbx=gdmbx;
this.msmbx=msmbx;

gen = new(gdmbx);
drv = new(gdmbx);
mon = new(msmbx);
sco = new(msmbx);
endfunction



task run();

gen.done=gddone;
drv.done=gddone;
drv.vif=vif;
mon.vif=vif;

fork 
 gen.run();
 drv.run();
 mon.run();
 sco.run();
 
join_any

endtask
endclass



module tb;

environment env;
mailbox gdmbx;
mailbox msmbx;
gray_enc_intf vif();

gray_enc_dec dut(vif.din,vif.sel,vif.dout);
initial begin
gdmbx=new();
msmbx=new();
env=new(gdmbx,msmbx);
env.vif=vif;

env.run();
#200;
$finish;

end
endmodule
