`include "regn.sv"
`include "dec3to8.sv"

module proc (DIN, Resetn, Clock, Run, Done, BusWires);
	input [8:0]DIN; //Data input
	input Resetn, Clock, Run;
	output Done;
	output [8:0] BusWires;
	logic Done, Ain, Gin, Gout, AddSub, IRin, DINout;
	logic [1:0] Tstep_Q, Tstep_D; //States
	logic [2:0] I; //Instruction
	logic [7:0] Xreg, Yreg, Rin, Rout;
   logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7, A, G, Sum, BusWires, IR; //registers trails
	logic [9:0] Sel; //Mux Selector
	
	parameter T0 = 2'b00, T1 = 2'b01, T2 = 2'b10, T3 = 2'b11; //Estados
   parameter mv = 3'b000, mvi = 3'b001, add = 3'b010, sub = 3'b011; //Instruçoes

	assign I = IR[2:0];
	dec3to8 decX (IR[5:3], 1'b1, Xreg);
	dec3to8 decY (IR[8:6], 1'b1, Yreg);

	// Controle de estados do FSM	

	always @(Tstep_Q, Run, Done)
	
	begin
		case (Tstep_Q)
			T0:
				if (~Run) Tstep_D = T0;
				else Tstep_D = T1;
			T1:
				if (Done) Tstep_D = T0;
				else Tstep_D = T2;
			T2: 
				Tstep_D = T3;
			T3:
				Tstep_D = T0;
			default:
				Tstep_D = T0;
		endcase
	end

	// Controle das saídas da FSM
	always @(Tstep_Q or I or Xreg or Yreg)
	begin
		case (Tstep_Q)
			T0: 
				begin
					IRin = 1'b1;
					Done = 1'b0;
					Rin = 1'b0;
					Rout = 1'b0;
					Xreg = 1'b0;
					Yreg = 1'b0;
				end
			T1:   
				case (I)
					mv: 
					begin
						Rout = Yreg;
						Rin = Xreg;
						Done = 1'b1;
					end
					mvi: 
					begin
						DINout = 1'b1;
						Rin = Xreg; 
						Done = 1'b1;
					end
					default: Done = 1'b0;
				endcase
			default: Done = 1'b0;
		endcase
    end

	// Controle os flip-flops do FSM
	always @(posedge Clock, negedge Resetn)
		if (!Resetn)
			Tstep_Q <= T0;
		else
			Tstep_Q <= Tstep_D;

		regn reg_0 (BusWires, Rin[0], Clock, R0);
		regn reg_1 (BusWires, Rin[1], Clock, R1);
		regn reg_2 (BusWires, Rin[2], Clock, R2);
		regn reg_3 (BusWires, Rin[3], Clock, R3);
		regn reg_4 (BusWires, Rin[4], Clock, R4);
		regn reg_5 (BusWires, Rin[5], Clock, R5);
		regn reg_6 (BusWires, Rin[6], Clock, R6);
		regn reg_7 (BusWires, Rin[7], Clock, R7);
		regn reg_A (BusWires, Ain, Clock, A);
		regn reg_G (Sum, Gin, Clock, G);
		regn reg_IR (DIN[8:0], IRin, Clock, IR);
		
		
	//ULA
	always @(AddSub or A or BusWires)
		begin
		if (~AddSub)
			Sum = A + BusWires;
	    else
			Sum = A - BusWires;
		end
		
	assign Sel = {Rout, Gout, DINout};
	
	always @(*)
	begin
		if (Sel == 10'b1000000000) BusWires = R7;
   	else if (Sel == 10'b0100000000) BusWires = R6;
		else if (Sel == 10'b0010000000) BusWires = R5;
		else if (Sel == 10'b0001000000) BusWires = R4;
		else if (Sel == 10'b0000100000) BusWires = R3;
		else if (Sel == 10'b0000010000) BusWires = R2;
		else if (Sel == 10'b0000001000) BusWires = R1;
		else if (Sel == 10'b0000000100) BusWires = R0;
		else if (Sel == 10'b0000000010) BusWires = G;
   	else BusWires = DIN;
	end	
endmodule




