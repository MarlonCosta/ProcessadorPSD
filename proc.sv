module proc (DIN, Resetn, Clock, Run, Done, BusWires);
	input [8:0]DIN; //Data input
	input Resetn, Clock, Run;
	output Done;
	output [8:0] BusWires;
	logic Done, Ain, Gin, Gout, AddSub, IRin, DINout;
	logic [1:0] state; //States
	logic [2:0] I; //Instruction
	logic [7:0] Xreg, Yreg, Rin, Rout;
	logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7, A, G, Sum, BusWires, IR; //registers trails
	logic [9:0] Sel; //Mux Selector
	
	parameter T0 = 2'b00, T1 = 2'b01, T2 = 2'b10, T3 = 2'b11; //Estados
   parameter mv = 3'b000, mvi = 3'b001, add = 3'b010, sub = 3'b011; //Instruçoes

	assign I = IR[8:6]; //000
	dec3to8 decX (IR[5:3], 1'b1, Xreg); //000 -> 00000001
	dec3to8 decY (IR[2:0], 1'b1, Yreg); //000 -> 00000001

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
	
	assign Sel = {Rout, Gout, DINout}; //Seletor do Mux
	
	// Controle de estados do FSM	
	
	always @(*)
		begin
		if 	  (Sel == 10'b1000000000) BusWires = R7;
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
	
	always @ (posedge Clock or negedge Resetn)
		begin
		if (!Resetn)
			begin
			IRin = 1'b0;
			state = T0;		
			end
		else
			begin
			unique case(state)
			T0:
			begin
				IRin = 1'b1;
				Done = 1'b0;
				Rout = 8'b0;
				Gout = 1'b0;
				DINout = 1'b0;
				if (Run)
					state = T1;
				else
					state = T0;
			end
			
			T1:
				unique case(I)
					mv:
						begin
						Rout = Yreg;
						Rin = Xreg;
						Done = 1'b1;
						state = T0;
						end
					mvi:
						begin
						DINout = 1'b1;
						Rin = Xreg; 
						Done = 1'b1;
						state = T0;
						end
					add,sub:
						begin
						Rout = Xreg;
						Ain = 1'b1;
						state = T2;
						end						
					default: state = T0;
				endcase
				
			T2:
				unique case(I)
					add:
						begin
						Rout = Yreg;
						Gin = 1'b1;
						state = T3;
						end
					sub:
						begin
						Rout = Yreg;
						AddSub = 1'b1;
						Gin = 1'b1;
						state = T3;
						end
						
					default: state = T0;
				endcase
			
			T3:
			unique case(I)
					add, sub: 
						begin
						Gout = 1'b1;
						Rin = Xreg;
						Done = 1'b1;
						state = T0;
						end
					default: state = T0;
				endcase
			endcase
		end
		end

//	always @(Tstep_Q, Run, Done)
//	
//	begin
//		unique case((Tstep_Q)
//			T0:
//				if (~Run) Tstep_D = T0;
//				else Tstep_D = T1;
//			T1:
//				if (Done) Tstep_D = T0;
//				else Tstep_D = T2;
//			T2: 
//				Tstep_D = T3;
//			T3:
//				Tstep_D = T0;
//			default:
//				Tstep_D = T0;
//		endcase
//	end
//
//	// Controle das saídas da FSM
//	always @(Tstep_D or I or Xreg or Yreg)
//	begin
//		unique case((Tstep_D)
//			T0: 
//				begin
//					IRin = 1'b1;
//					Done = 1'b0;
//					Ain = 1'b0;
//					Gin = 1'b0;
//					Gout = 1'b0;
//					AddSub = 1'b0;
//					IRin = 1'b0;
//					DINout = 1'b0;
//					Rin = 8'b0;
//					Rout = 8'b0;
//				end
//			T1:   
//				unique case((I)
//					mv: 
//					begin
//						Rout = Yreg;
//						Rin = Xreg;
//						Done = 1'b1;
//						IRin = 1'b1;
//						Ain = 1'b0;
//						Gin = 1'b0;
//						Gout = 1'b0;
//						AddSub = 1'b0;
//						IRin = 1'b0;
//						DINout = 1'b0;
//					end
//					mvi: 
//					begin
//						DINout = 1'b1;
//						Rin = Xreg; 
//						Done = 1'b1;
//						IRin = 1'b1;
//						Ain = 1'b0;
//						Gin = 1'b0;
//						Gout = 1'b0;
//						AddSub = 1'b0;
//						IRin = 1'b0;
//						Rout = 8'b0;
//					end
//					add, sub:
//					begin
//						Rout = Xreg;
//						Ain = 1'b1;
//						IRin = 1'b1;
//						Done = 1'b0;
//						Gin = 1'b0;
//						Gout = 1'b0;
//						AddSub = 1'b0;
//						IRin = 1'b0;
//						DINout = 1'b0;
//						Rin = 8'b0;
//					end
//					default: 		
//						begin
//						IRin = 1'b0;
//						Done = 1'b0;
//						Ain = 1'b0;
//						Gin = 1'b0;
//						Gout = 1'b0;
//						AddSub = 1'b0;
//						IRin = 1'b0;
//						DINout = 1'b0;
//						Rin = 8'b0;
//						Rout = 8'b0;
//						end
//				endcase
//					
//			T2:   
//				unique case((I)
//					add: 
//					begin
//						Rout = Yreg;
//						Gin = 1'b1;
//						IRin = 1'b1;
//						Done = 1'b0;
//						Ain = 1'b0;
//						Gout = 1'b0;
//						AddSub = 1'b0;
//						IRin = 1'b0;
//						DINout = 1'b0;
//						Rin = 8'b0;
//					end
//					sub: 
//					begin
//						Rout = Yreg;
//						AddSub = 1'b1;
//						Gin = 1'b1;
//						IRin = 1'b1;
//						Done = 1'b0;
//						Ain = 1'b0;
//						Gout = 1'b0;
//						IRin = 1'b0;
//						DINout = 1'b0;
//						Rin = 8'b0;
//					end
//					default: 
//						begin
//						IRin = 1'b1;
//						Done = 1'b0;
//						Ain = 1'b0;
//						Gin = 1'b0;
//						Gout = 1'b0;
//						AddSub = 1'b0;
//						IRin = 1'b0;
//						DINout = 1'b0;
//						Rin = 8'b0;
//						Rout = 8'b0;
//						end
//				endcase
//			T3:  
//				unique case((I)
//					add, sub: 
//					begin
//						Gout = 1'b1;
//						Rin = Xreg;
//						Done = 1'b1;
//						IRin = 1'b1;
//						Ain = 1'b0;
//						Gin = 1'b0;
//						AddSub = 1'b0;
//						IRin = 1'b0;
//						DINout = 1'b0;
//						Rout = 8'b0;
//					end
//					default:
//						begin
//						IRin = 1'b1;
//						Done = 1'b0;
//						Ain = 1'b0;
//						Gin = 1'b0;
//						Gout = 1'b0;
//						AddSub = 1'b0;
//						IRin = 1'b0;
//						DINout = 1'b0;
//						Rin = 8'b0;
//						Rout = 8'b0;
//						end
//				endcase
//			default: 
//				begin
//				IRin = 1'b0;
//				Done = 1'b0;
//				Ain = 1'b0;
//				Gin = 1'b0;
//				Gout = 1'b0;
//				AddSub = 1'b0;
//				IRin = 1'b0;
//				DINout = 1'b0;
//				Rin = 8'b0;
//				Rout = 8'b0;
//				end
//		endcase
//    end

	// Controle os flip-flops do FSM
//	always @(posedge Clock, negedge Resetn)
//		if (!Resetn)
//			Tstep_Q <= T0;
//		else
//			Tstep_Q <= Tstep_D;
		
	//ULA
	always @(AddSub or A or BusWires)
		begin
		if (~AddSub)
			Sum = A + BusWires;
	    else
			Sum = A - BusWires;
		end
		
//	
	

endmodule




