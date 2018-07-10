module proc (DIN, Resetn, Clock, Run, Done, BusWires);
	input [8:0]DIN; 
	input Resetn, Clock, Run;
	output Done;
	output [8:0] BusWires;
	reg [0:7] Rin, Rout;
	reg Done, Ain, Gin, Gout, AddSub, IRin, DINout;
	reg [1:0] Tstep_Q, Tstep_D; //States
	wire [2:0] I; //Instruction
	wire [0:8] IR; //Instruction Register
	wire [0:7] Xreg, Yreg;  //Operation Registers
   wire [8:0] R0, R1, R2, R3, R4, R5, R6, R7, A, G; //Registers trails
	reg [8:0] Sum; //Sum output register
	wire [0:9] Sel; //Mux Selector
	reg [8:0] BusWires;
	
	//variaveis faltando: 
	
	parameter T0 = 2'b00, T1 = 2'b01, T2 = 2'b10, T3 = 2'b11;
   parameter mv = 3'b000, mvi = 3'b001, add = 3'b010, sub = 3'b011;

	assign I = IR[0:2];
	dec3to8 decX (IR[3:5], 1'b1, Xreg);
	dec3to8 decY (IR[6:8], 1'b1, Yreg);

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
					add, sub: 
					begin
						Rout = Xreg;
						Ain = 1'b1;
					end
				endcase
//			T2:   
//				case (I)
//					add: 
//					begin
//						Rout = Yreg;
//						Gin = 1'b1;
//					end
//					sub: 
//					begin
//						Rout = Yreg;
//						AddSub = 1'b1;
//						Gin = 1'b1;
//					end
//				endcase
//			T3:  
//				case (I)
//					add, sub: 
//					begin
//						Gout = 1'b1;
//						Rin = Xreg;
//						Done = 1'b1;
//					end
//				endcase
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
		regn reg_IR (DIN[8:0], IRin, Clock, IR);
		
	always @(AddSub or A or BusWires)
		begin
		if (!AddSub)
			Sum = A + BusWires;
	    else
			Sum = A - BusWires;
		end
		
	regn reg_G (Sum, Gin, Clock, G);
	
	assign Sel = {Rout, Gout, DINout};
	always @(*)
	begin
		if (Sel == 10'b1000000000)
			BusWires = R0;
   	else if (Sel == 10'b0100000000)
			BusWires = R1;
		else if (Sel == 10'b0010000000)
			BusWires = R2;
		else if (Sel == 10'b0001000000)
			BusWires = R3;
		else if (Sel == 10'b0000100000)
			BusWires = R4;
		else if (Sel == 10'b0000010000)
			BusWires = R5;
		else if (Sel == 10'b0000001000)
			BusWires = R6;
		else if (Sel == 10'b0000000100)
			BusWires = R7;
		else if (Sel == 10'b0000000010)
			BusWires = G;
   	else BusWires = DIN;
	end	
endmodule


module dec3to8(W, En, Y);
//Decodificador 3 para 8
	input [2:0] W;
	input En;
	output [0:7] Y;
	reg [0:7] Y;
	
	always @(W or En)
	begin
	if (En == 1)
	case (W)
		3'b000: Y = 8'b10000000;
		3'b001: Y = 8'b01000000;
		3'b010: Y = 8'b00100000;
		3'b011: Y = 8'b00010000;
		3'b100: Y = 8'b00001000;
		3'b101: Y = 8'b00000100;
		3'b110: Y = 8'b00000010;
		3'b111: Y = 8'b00000001;
	endcase
	else
		Y = 8'b00000000;
	end
endmodule

module regn(R, Rin, Clock, Q);
//Bloco registrador
//R = Entrada
//Rin = Enable

	parameter n = 9;
	input [n-1:0] R;
	input Rin, Clock;
	output [n-1:0] Q;
	reg [n-1:0] Q;
	
	always @(posedge Clock)
	if (Rin)
		Q <= R;
endmodule