module fpadder
(
	output	logic [31:0] sum,
	output	logic ready,
	input	logic [31:0] a,
	input	logic clock,
	input	logic nreset
);
//enum {start,loada, loadb,sign,exp_equal,add_m,normalise} present_state, next_state;
enum {over,start,loada,loadb,process,zerock,exp_equal,add_m,normalise} present_state, next_state;
reg	[25:0]	mx;
reg	[25:0]	my;
reg 	[25:0]	m_result;

reg	[7:0]	ex;
reg	[7:0]	ey;
reg 	[7:0]	e_result;

reg 	[31:0]	ix;
reg	[31:0]	iy;

//assign result=(present_state==start)?{m_result[25],e_result[7:0],m_result[22:0]}:'b0;

assign sum = (present_state==start)?{m_result[25],e_result[7:0],m_result[22:0]}:'bX;
assign ready = (present_state==start)? 1:0;

//always_ff @(posedge clock or negedge nreset) begin
//	if(nreset == 1'b0)begin
//		sum <= 'b0;
//	end
//	else begin
//		if(present_state == start)
//		begin
//			sum <= {m_result[25],e_result[7:0],m_result[22:0]};
//		end
//		else
//			sum <= sum;
//	end
//end

//always_ff @(posedge clock or negedge nreset) begin
//	if(nreset == 1'b0)begin
//		ready <= 'b0;
//	end
//	else begin
//		if(present_state == start)
//		begin
//			ready <= 1'b1;
//		end
//		else
//			ready <= 1'b0;
//	end
//end

always_ff  @(posedge clock or negedge nreset)begin
    if(nreset==1'b0)begin
		present_state <= over;
    end
    else begin
		present_state <= next_state;
    end
end

always_ff  @(posedge clock or negedge nreset)begin
    if(nreset==1'b0)begin
		ix <= 'bX;
    end
    else begin
	    if(present_state == loada)
	    begin
		    ix <= a;		
	    end
    end
end

always_ff  @(posedge clock or negedge nreset)begin
    if(nreset==1'b0)begin
		iy <= 'bX;
    end
    else begin
	    if(present_state == loadb)
	    begin
		    iy <= a;
	    end
    end
end

always_comb
begin
	unique case(present_state)
		start:begin
			next_state = loada;
		end
		loada:begin
			next_state = loadb;
		end
		loadb:begin
			next_state = process;
		end
        process:begin
            ex = ix[30:23];
            mx = {ix[31],1'b0,1'b1,ix[22:0]};

            ey = iy[30:23];
            my = {iy[31],1'b0,1'b1,iy[22:0]};
            next_state = zerock;
        end

		zerock:begin
			if(ix == 0)// -0 +0 @ to do
			begin
				{e_result, m_result} = {ey,my};
				next_state = over;
			end	
			else if(iy==0)
			begin
				{e_result, m_result} = {ex,mx};
				next_state = over;
			end
			else if(ex == 8'b1111_1111 && ey != 8'b1111_1111 )
			begin
				e_result = ex;
				m_result = mx;
				next_state = over;
			end
			else if(ex != 8'b1111_1111 && ey == 8'b1111_1111 )
			begin
				e_result = ey;
				m_result = my;
				next_state = over;
			end
			else
				next_state = exp_equal;
		end
		exp_equal:begin
			if(ex > ey)
			begin
				ey = ey + 1;
                // @ todo
				my[24:0] = {1'b0,my[24:1]};
				if(my == 0)
				begin
					m_result = mx;
					e_result = ex;
					next_state = over;
				end
				else
					next_state = exp_equal;	
			end
			else if(ex < ey)
			begin
				ex = ex + 1;
				mx[24:0] = {1'b0,mx[24:1]};
				if(mx == 0)
				begin
					m_result = my;
					e_result = ey;
					next_state = over;
				end
				else
					next_state = exp_equal;
			end
			else
			begin
				e_result = ex;
				next_state = add_m;
			end
		end
		add_m : begin
			if(mx[25] == my[25])
			begin
				m_result[25] = mx[25];
				m_result[24:0] = mx[24:0]+my[24:0];
			end
			else if(mx[25] != my[25])
			begin
				if(mx[24:0]>my[24:0])//mx > my
				begin
					m_result[25] = mx[25];
					m_result[24:0] = mx[24:0] - my[24:0];
				end
				else if(mx[24:0] < my[24:0])
				begin
					m_result[25] = my[25];
					m_result[24:0] = my[24:0] - mx[24:0];
				end
				else
				begin
					m_result = 'b0;
					next_state = over;
				end 
			end
			next_state = normalise;	
		end
		normalise:begin
			if(m_result[24]==1)
			begin
				m_result[24:0] = {1'b0,m_result[24:1]};
				e_result = e_result +1;
				next_state = over;
			end
			else if(m_result[23]==0)
			begin
				m_result[24:0] = {m_result[23:0],1'b0};
				e_result = e_result -1;
				next_state = normalise;
			end
			else
				next_state = over;
		end
        over:begin
            next_state = start;
        end
	endcase
end


endmodule






















