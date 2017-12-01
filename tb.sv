module tb_fpadder;

fpadder d0(.*);
//ʱ�Ӻ͸�λ
logic clock  ;
logic nreset;
logic [31:0] a;
logic [31:0] sum;
logic ready;

//ʱ�����ڣ���λΪns�����ڴ��޸�ʱ�����ڡ�
parameter CYCLE    = 20;

//��λʱ�䣬��ʱ��ʾ��λ3��ʱ�����ڵ�ʱ�䡣
parameter RST_TIME = 3 ;

//���ɱ���ʱ��50M
initial begin
    clock = 0;
    forever #(CYCLE/2)    clock=~clock;
end

//������λ�ź�
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
