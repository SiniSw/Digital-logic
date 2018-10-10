`timescale 1ns / 1ps
module MainSystem(
    input reset,            //Reset信号
    input CLK,              //系统时钟
    input Control,          //洗衣模式选择
    input SP,               //启动/暂停
    input [2:0]CWS,         //衣物重量传感器
    output reg [6:0]seg,
    output reg [7:0]an,    
    output wire RL,          //电源/运行指示灯
    output reg SPL,         //启动/暂停灯
    output reg XDL,         //洗涤灯
    output reg PXL,         //漂洗灯
    output reg TSL,         //脱水灯
    output reg BUL,         //蜂鸣警报灯
    output wire JSL,         //进水灯
    output wire PSL          //排水灯          
    );
    parameter idle  =4'b0000;
    parameter water1=4'b0001;
    parameter wash  =4'b0011;
    parameter drain1=4'b0111;
    parameter dry1  =4'b0110;
    parameter water2=4'b0100;
    parameter rinse =4'b1100;
    parameter drain2=4'b1000;
    parameter dry2  =4'b1001;
    parameter dor   =4'b1111;
    parameter SEC   =31'd10;   // sec/clk 30000000  sim/10
    parameter AN_CLK=16'd1000;
    parameter LED_CLK=31'd2; //10000000   sim/2
    parameter BUL_CLK=31'd2; //20000000   sim/2
    reg flag1,flag2;
    reg Control_p;
    reg reset_p;
    reg Reset_p;
    reg SP_p;
    reg Reset;
    reg [4:0]now;
    reg [4:0]next;
    reg [2:0]state;
    reg [31:0]led_count;
    reg [15:0]count;
    reg [5:0]t_count;
    reg [31:0]sec;
    reg [4:0]n_count;
    reg w,d;
    reg [1:0]b;
    reg [31:0]b_time;
    reg [1:0]led[0:2];
    reg [2:0]b_count;
    wire [3:0]t_count_s;
    wire [3:0]t_count_t;
    wire [3:0]n_count_s;
    wire [3:0]n_count_t;
    reg [6:0]data_out[0:5];
    reg [2:0]WLS;
    assign t_count_s=t_count%4'd10;
    assign t_count_t=t_count/4'd10;
    assign n_count_s=n_count%4'd10;
    assign n_count_t=n_count/4'd10;
    assign RL=Reset;
    assign JSL=w;
    assign PSL=d;

    initial begin
        Control_p=1'b0;
        Reset_p=1'b0;
        Reset=1'b0;
        reset_p=1'b0;
        SP_p=1'b0;
        flag1=1'b0;
        flag2=1'b0;
        count=0;
        led_count=0;
        b_time=0;
        end  
    always@(posedge CLK)
        begin 
            count=count+1;
            if(count==AN_CLK)
               begin flag1<=~flag1;
                     count<=0;
               end
        end  
    always@(posedge flag1)
        begin
            case(an)
                8'b11111110:begin seg<=data_out[0];an<={~Reset,7'b1111111}; end
                8'b01111111:begin seg<=data_out[1];an<={1'b1,~Reset,6'b111111}; end
                8'b10111111:begin seg<=7'b1111111; an<={2'b11,~Reset,5'b11111}; end
                8'b11011111:begin seg<=7'b1111111; an<={3'b111,~Reset,4'b1111}; end
                8'b11101111:begin seg<=data_out[2];an<={4'b1111,~Reset,3'b111}; end
                8'b11110111:begin seg<=data_out[3];an<={5'b11111,~Reset,2'b11}; end
                8'b11111011:begin seg<=data_out[4];an<={6'b111111,~Reset,1'b1}; end
                8'b11111101:begin seg<=data_out[5];an<={7'b1111111,~Reset}; end
                default:begin seg<=7'b1111111;an<={~Reset,7'b1111111}; end
            endcase
        end
    always@(CWS)
        begin 
            case(CWS)
                3'b010:begin data_out[4]<=7'b0100100; end
                3'b011:begin data_out[4]<=7'b0110000; end
                3'b100:begin data_out[4]<=7'b0011001; end
                3'b101:begin data_out[4]<=7'b0010010; end
               default:begin data_out[4]<=7'b1111111; end
            endcase
        end
    always@(WLS)
        begin
            case(WLS)
                3'b000:begin data_out[5]<=7'b1000000; end
                3'b001:begin data_out[5]<=7'b1111001; end
                3'b010:begin data_out[5]<=7'b0100100; end
                3'b011:begin data_out[5]<=7'b0110000; end
                3'b100:begin data_out[5]<=7'b0011001; end
                3'b101:begin data_out[5]<=7'b0010010; end
               default:begin data_out[5]<=7'b1111111; end
            endcase
        end
    always@(t_count_t)
            begin
                case(t_count_t)
                    4'b0000:data_out[0]=7'b1000000;
                    4'b0001:data_out[0]=7'b1111001;
                    4'b0010:data_out[0]=7'b0100100;
                    4'b0011:data_out[0]=7'b0110000;
                    4'b0100:data_out[0]=7'b0011001;
                    4'b0101:data_out[0]=7'b0010010;
                    4'b0110:data_out[0]=7'b0000010;
                    4'b0111:data_out[0]=7'b1111000; 
                    4'b1000:data_out[0]=7'b0000000;
                    4'b1001:data_out[0]=7'b0011000;
                    default:data_out[0]=7'b1111111; 
                endcase
            end   
    always@(t_count_s)
        begin
            case(t_count_s)
                    4'b0000:data_out[1]=7'b1000000;
                    4'b0001:data_out[1]=7'b1111001;
                    4'b0010:data_out[1]=7'b0100100;
                    4'b0011:data_out[1]=7'b0110000;
                    4'b0100:data_out[1]=7'b0011001;
                    4'b0101:data_out[1]=7'b0010010;
                    4'b0110:data_out[1]=7'b0000010;
                    4'b0111:data_out[1]=7'b1111000; 
                    4'b1000:data_out[1]=7'b0000000;
                    4'b1001:data_out[1]=7'b0011000;
                    default:data_out[1]=7'b1111111; 
            endcase
        end
    always@(n_count_t)
            begin
                case(n_count_t)
                    4'b0000:data_out[2]=7'b1000000;
                    4'b0001:data_out[2]=7'b1111001;
                    4'b0010:data_out[2]=7'b0100100;
                    4'b0011:data_out[2]=7'b0110000;
                    4'b0100:data_out[2]=7'b0011001;
                    4'b0101:data_out[2]=7'b0010010;
                    4'b0110:data_out[2]=7'b0000010;
                    4'b0111:data_out[2]=7'b1111000; 
                    4'b1000:data_out[2]=7'b0000000;
                    4'b1001:data_out[2]=7'b0011000;
                    default:data_out[2]=7'b1111111; 
                endcase
            end   
    always@(n_count_s)
                begin
                    case(n_count_s)                   
                    4'b0000:data_out[3]=7'b1000000;
                    4'b0001:data_out[3]=7'b1111001;
                    4'b0010:data_out[3]=7'b0100100;
                    4'b0011:data_out[3]=7'b0110000;
                    4'b0100:data_out[3]=7'b0011001;
                    4'b0101:data_out[3]=7'b0010010;
                    4'b0110:data_out[3]=7'b0000010;
                    4'b0111:data_out[3]=7'b1111000; 
                    4'b1000:data_out[3]=7'b0000000;
                    4'b1001:data_out[3]=7'b0011000;
                    default:data_out[3]=7'b1111111; 
                    endcase
                end            
    always@(posedge CLK)
        begin 
            led_count=led_count+1;
            if(led_count==LED_CLK)
               begin flag2<=~flag2;
                     led_count<=0;
               end
        end  
    always@(posedge flag2)
        begin 
            case(led[0])
                2'b00:TSL=0;
                2'b01:TSL=1;
                2'b10:TSL=~TSL;
            endcase            
            case(led[1])
                2'b00:PXL=0;
                2'b01:PXL=1;
                2'b10:PXL=~PXL;
            endcase
            case(led[2])
                2'b00:XDL=0;
                2'b01:XDL=1;
                2'b10:XDL=~XDL;
            endcase
       end     
    always@(negedge CLK)
        begin
           now<=next;
        end
    always@(posedge CLK)
        begin
        if(reset_p==1'b0&&reset==1'b1)
            Reset=~Reset;
        if(Reset_p!=Reset)begin
        if(Reset)begin w<=0;d<=0;b<=0;
               sec<=SEC;
               t_count<=21+4*CWS;
               next<=idle;
               SPL<=0;
               state=3'b111;
               led[0]={1'b0,state[0]};
               led[1]={1'b0,state[1]};
               led[2]={1'b0,state[2]};  
               end
           else begin  w<=0;d<=0;b<=0;
                       t_count<=0;n_count<=0;
                       SPL<=0;
                       state=3'b000;
                       led[0]={1'b0,state[0]};
                       led[1]={1'b0,state[1]};
                       led[2]={1'b0,state[2]};                         
                end
         end
         if(Reset==1&&SPL==0)begin
             if(Control_p==1'b0&&Control==1'b1) begin
                  b=2'b01;
              case(state)
                  3'b111:begin state=3'b100;next=idle;t_count=9+CWS; end
                  3'b100:begin state=3'b110;next=idle;t_count=18+3*CWS; end
                  3'b110:begin state=3'b010;next=idle;t_count=9+2*CWS; end
                  3'b010:begin state=3'b011;next=idle;t_count=12+3*CWS; end
                  3'b011:begin state=3'b001;next=idle;t_count=3+CWS; end
                  3'b001:begin state=3'b111;next=idle;t_count=21+4*CWS; end
                  default: begin state=3'b111;next=idle;t_count=21+4*CWS; end
              endcase
                 WLS=0;sec=SEC;
                 n_count=0;
                 led[0]={1'b0,state[0]};
                 led[1]={1'b0,state[1]};
                 led[2]={1'b0,state[2]};  
              end
          end
         if(Reset==1)begin
         if(SP_p==1'b0&&SP==1'b1)begin
               b<=2'b01;
               if(SPL&&Reset)SPL=0;
                  else SPL=1;
             end
         end
         SP_p<=SP;
         Control_p<=Control;  
         reset_p<=reset;
         Reset_p<=Reset;
         case(b)
             2'b00:begin BUL<=0;end
             2'b01:begin BUL<=1;b_count<=1;b<=2'b11; end
             2'b10:begin BUL<=1;b_count<=5;b<=2'b11; end
             2'b11:begin 
                     b_time<=b_time+1;
                     if(b_time>=BUL_CLK)begin BUL<=~BUL;b_count<=b_count-1;b_time<=0; end
                     if(b_count==0)begin BUL<=0; b<=2'b00; end
             end
         endcase           
        if(Reset&&SPL)begin
            case(now)
                idle:if(state[2])begin w<=1;d<=0;b<=0;
                             n_count<=CWS+9;
                             led[2]<=2;
                             next<=water1;
                             end
                  else begin if(state[1])begin w<=0;d<=1;b<=0;
                                    n_count<=2*CWS+9;
                                    WLS<=CWS;
                                    led[1]<=2;
                                    next<=drain1;
                                   end
                    else begin w<=0;d<=1;b<=0;
                          WLS<=CWS;
                          n_count<=3+CWS;
                          led[0]<=2;
                          next<=drain2;
                         end
                       end
            water1:if(n_count==9) 
                    begin w<=0;d<=0;b<=0; next<=wash; 
                    end 
                   else begin  sec=sec-1;
                      if(sec==0)begin n_count<=n_count-1;
                                      WLS<=WLS+1;
                                      t_count<=t_count-1;
                                      sec=SEC;
                                end
                         end 
            wash:if(n_count==0)                  
                    begin led[2]=0;
                    if(state[1]==1)begin 
                        w<=0;d<=1;b<=0;
                        n_count<=9+2*CWS;
                        led[1]<=2;
                        next<=drain1;
                        end
                    else begin w<=0;d<=0;b<=2'b10;led[2]<=0; next<=dor;
                              sec<=10*SEC;
                         end 
                    end                          
                   else begin sec=sec-1;
                   if(sec==0)begin n_count<=n_count-1;
                                   t_count<=t_count-1;
                                   sec<=SEC;
                             end
                        end
            drain1:if(n_count==9+CWS)                    
                    begin w<=0;d<=0;b<=0; next<=dry1; 
                    end 
                   else begin  sec=sec-1;
                      if(sec==0)begin n_count<=n_count-1;
                                      WLS<=WLS-1;
                                      t_count<=t_count-1;
                                      sec<=SEC;
                                end
                         end 
            dry1:if(n_count==6+CWS)                    
                    begin w<=1;d<=0;b<=0; next<=water2; 
                    end 
                   else begin  sec=sec-1;
                      if(sec==0)begin n_count<=n_count-1;
                                      t_count<=t_count-1;
                                      sec<=SEC;
                                end
                         end         
            water2:if(n_count==6)                    
                     begin w<=0;d<=0;b<=0; next<=rinse; 
                     end 
                   else begin  sec=sec-1;
                     if(sec==0)begin n_count<=n_count-1;
                                     WLS<=WLS+1;
                                     t_count<=t_count-1;
                                     sec<=SEC;
                               end
                        end 
            rinse:if(n_count==0)                  
                   begin led[1]=0;
                   if(state[0]==1)begin 
                      w<=0;d<=1;b<=0;
                      n_count<=3+CWS;
                      led[0]<=2;
                      next<=drain2;
                      end
                   else begin w<=0;d<=0;b<=2'b10;led[1]<=0; next<=dor; 
                            sec<=10*SEC;
                        end
                   end                         
                  else begin  sec=sec-1;
                     if(sec==0)begin n_count<=n_count-1;
                                     t_count<=t_count-1;
                                     sec<=SEC;
                               end
                        end 
             drain2:if(n_count==3)                    
                           begin w<=0;d<=0;b<=0; next<=dry2; 
                           end 
                   else begin  sec=sec-1;
                             if(sec==0)begin n_count<=n_count-1;
                                             WLS<=WLS-1;
                                             t_count<=t_count-1;
                                             sec<=SEC;
                                       end
                                end 
             dry2:if(n_count==0)                    
                           begin w<=0;d<=0;b<=2'b10;led[0]<=0; next<=dor; 
                                 sec<=10*SEC;
                           end 
                   else begin  sec=sec-1;
                             if(sec==0)begin n_count<=n_count-1;
                                             t_count<=t_count-1;
                                             sec<=SEC;
                                       end
                                end      
             default: begin sec=sec-1;
                            if(sec==0) begin 
                                             Reset<=0;
                                       end
                      end     
        endcase
        end     
      end   
endmodule