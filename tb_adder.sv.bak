module tb_adder;
fpadder a1 (.*);
logic [31:0] sum;
logic ready;
logic [31:0] a;
logic clock, nreset;
shortreal reala, realsum;

initial
begin
nreset = '1;
clock ='0;
#5ns nreset ='1;
#5ns nreset ='0;
#5ns nreset = '1;
forever #5ns clock = ~clock;
end
initial
begin
@(posedge clock); // wait for clock to start
@(posedge ready); // wait for ready
@(posedge clock); //wait for next clock tick
reala = 1.0;
a = $shortrealtobits(reala);
@(posedge clock);
reala = 0;
a = $shortrealtobits(reala);
@(posedge ready);
realsum = $bitstoshortreal(sum);
$display("%f\n", realsum);
end
endmodule