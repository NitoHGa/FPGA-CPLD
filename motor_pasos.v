module Motor_Pasos(
	input clk, //Señal de reloj 50MHz
	input inc, dec, en, //Pulsadores para cambio de velocidad y activación
	output [3:0]AB	//Salidas para motor a pasos
);
	//Declaración de registros (variables internas)
	reg [31:0]cnt, frecuencia;
	reg [3:0]edo, nextedo;
	reg senal;
	//Iniciallización de variables 
	initial begin
		frecuencia = 200_000;
		edo = 1;
		senal = 0;
		cnt = 0;
	end 
	
	
	//Bloque de instrucciones para divisor de frecuencia
	always@(posedge clk) begin
		if(cnt > frecuencia) cnt <= 0;
		else begin
			if(cnt == frecuencia) begin
				cnt <= 0; 
				senal <= ~senal;
			end
			else cnt <= cnt + 1;
		end
	end
	//Bloque de instrucciones para manipulacion de frecuencia
	reg [31:0] cnt_rebote;
	reg [1:0] edo_rebote;
	initial edo_rebote = 0;
	always @(posedge clk) begin
		 case(edo_rebote)
			  0: begin
					if(inc == 0 && dec == 1) begin edo_rebote <= 1; cnt_rebote <= 0;end
					else if(dec == 0 && inc == 1) begin edo_rebote <= 2; cnt_rebote <= 0;end
			  end
			  1: begin
					if(frecuencia < 2_500_000) begin
						 if(cnt_rebote == 5_000_000) begin //Tiempo para que se quite el rebote
							  frecuencia <= frecuencia + 25_000;
							  edo_rebote <= 0;
						 end
						 else cnt_rebote <= cnt_rebote + 1; 
					end
					else edo_rebote <= 0;
			  end
			  2: begin
					if(frecuencia > 50_000) begin 
						 if(cnt_rebote == 5_000_000) begin //Tiempo para que se quite el rebote
							  frecuencia <= frecuencia - 25_000;
							  edo_rebote <= 0;
						 end
						 else cnt_rebote <= cnt_rebote + 1; 
					end
					else edo_rebote <= 0;
			  end
		 endcase
	end
	
	//Bloque de instrucciones para activacion de bobinas
	always@(posedge senal) begin
		case(en)
			1: begin
				case(edo)
					1:	nextedo <= (edo == 1)? 2:1; //Estado 0001
					2: nextedo <= (edo == 2)? 4:2; //Estado 0010
					4: nextedo <= (edo == 4)? 8:4; //Estado 0100
					8: nextedo <= (edo == 8)? 1:8; //Estado 1000
					default: nextedo <= 1; 
				endcase
			end
			0: nextedo <= 0; //Estado apagado 00
		endcase
	end always@(negedge senal) edo <= nextedo;
	
	//Asignacion de variables internas a variables fisicas.
	assign AB = edo;
endmodule
