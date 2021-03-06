module tb_fpadder;

fpadder d0(.*);
//时钟和复位
logic clock  ;
logic nreset;
logic [31:0] a;
logic [31:0] sum;
logic ready;

//时钟周期，单位为ns，可在此修改时钟周期。
parameter CYCLE    = 20;

//复位时间，此时表示复位3个时钟周期的时间。
parameter RST_TIME = 3 ;

//生成本地时钟50M
initial begin
    clock = 0;
    forever #(CYCLE/2)    clock=~clock;
end

//产生复位信号
initial begin
    nreset = 1;
    #2;
    nreset = 0;
    #(CYCLE*RST_TIME);
    nreset = 1;
    #1;
    #(CYCLE);
    a = 32'b00111111110000000000000000000000;
    #(CYCLE);
    a = 32'b01000000010000000000000000000000;

end

endmodule

