`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.06.2024 08:55:21
// Design Name: 
// Module Name: gray_enc
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



module gray_enc_dec #(parameter N=8)(
input [N-1:0] din,
input sel,
output reg [N-1:0] dout
    );
 
    integer i;
    always @(*)
    begin
    case (sel)
     1'b0: begin
         dout[N-1]=din[N-1];
                                            ///////bin2gray
       for(i=N-2;i>=0;i=i-1)
          dout[i]=din[i]+din[i+1];
    end
    
    1'b1: begin
       
       dout[N-1]=din[N-1];
       
       for(i=N-2;i>=0;i=i-1)            //////gray2bin
         dout[i]=din[i]+dout[i+1];
    
    end

    default: $display("No more operation");
endcase

end
endmodule
