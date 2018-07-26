module regn(R, Rin, Clock, Q);
//Bloco registrador
//R = Input
//Rin = Enable

	parameter n = 9;
	input [n-1:0] R;
	input Rin, Clock;
	output [n-1:0] Q;
	logic [n-1:0] Q;
	
	always @(posedge Clock)
	if (Rin)
		Q <= R;
	else
		Q <= Q;
endmodule