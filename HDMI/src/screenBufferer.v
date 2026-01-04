// ---------------------------------------------------------------------
// File name         : screenBufferer.v
// Module name       : screenBufferer
// Created by        : Caojie
// Module Description: display driver for BatPU_V2 fpga emulator
// ---------------------------------------------------------------------
// Release history
// VERSION |   Date      | AUTHOR  |    DESCRIPTION
// --------------------------------------------------------------------
//   1.0   | 24-Sep-2009 | Caojie  |    initial
// --------------------------------------------------------------------
//   2.0   |  1-Jan-2026 | Chamois |    BatPU_V2
// --------------------------------------------------------------------

module screenBufferer
(

    input      [31:0]  buffer[0:31]  ,// 32x32 pixel buffer
	input              I_pxl_clk   ,//pixel clock
    input              I_rst_n     ,//low active 
    input      [2:0]   I_mode      ,//data select
    input      [7:0]   I_single_r  ,
    input      [7:0]   I_single_g  ,
    input      [7:0]   I_single_b  ,
    input      [11:0]  I_h_total   ,//hor total time 
    input      [11:0]  I_h_sync    ,//hor sync time
    input      [11:0]  I_h_bporch  ,//hor back porch
    input      [11:0]  I_h_res     ,//hor resolution
    input      [11:0]  I_v_total   ,//ver total time 
    input      [11:0]  I_v_sync    ,//ver sync time  
    input      [11:0]  I_v_bporch  ,//ver back porch  
    input      [11:0]  I_v_res     ,//ver resolution 
    input              I_hs_pol    ,//HS polarity , 0:�����ԣ�1��������
    input              I_vs_pol    ,//VS polarity , 0:�����ԣ�1��������
    output             O_de        ,   
    output reg         O_hs        ,//������
    output reg         O_vs        ,//������
    output     [7:0]   O_data_r    ,    
    output     [7:0]   O_data_g    ,
    output     [7:0]   O_data_b    ,

    input      [7:0]   ram[0:255],
    input      [7:0]   mem[0:15]
); 

//====================================================
localparam N = 5; //delay N clocks

localparam	WHITE	= {8'd255 , 8'd255 , 8'd255 };//{B,G,R}
localparam	YELLOW	= {8'd0   , 8'd255 , 8'd255 };
localparam	CYAN	= {8'd255 , 8'd255 , 8'd0   };
localparam	GREEN	= {8'd0   , 8'd255 , 8'd0   };
localparam	MAGENTA	= {8'd255 , 8'd0   , 8'd255 };
localparam	RED		= {8'd0   , 8'd0   , 8'd255 };
localparam	BLUE	= {8'd255 , 8'd0   , 8'd0   };
localparam	BLACK	= {8'd0   , 8'd0   , 8'd0   };
localparam  LMPOFF  = {8'd0   , 8'd15  , 8'd31  };
localparam  LMPON   = {8'd0   , 8'd63  , 8'd127 };
localparam  ORANGE  = {8'd0   , 8'd64  , 8'd255 };
  
//====================================================
reg  [11:0]   V_cnt     ;
reg  [11:0]   H_cnt     ;
              
wire          Pout_de_w    ;                          
wire          Pout_hs_w    ;
wire          Pout_vs_w    ;

reg  [N-1:0]  Pout_de_dn   ;                          
reg  [N-1:0]  Pout_hs_dn   ;
reg  [N-1:0]  Pout_vs_dn   ;

//----------------------------
wire 		  De_pos;
wire 		  De_neg;
wire 		  Vs_pos;
	
reg  [11:0]   De_vcnt     ;
reg  [11:0]   De_hcnt     ;
reg  [11:0]   De_hcnt_d1  ;
reg  [11:0]   De_hcnt_d2  ;


//-------------------------------
reg  [23:0]   Data_tmp/*synthesis syn_keep=1*/;


//==============================================================================
//Generate HS, VS, DE signals
always@(posedge I_pxl_clk or negedge I_rst_n)
begin
	if(!I_rst_n)
		V_cnt <= 12'd0;
	else     
		begin
			if((V_cnt >= (I_v_total-1'b1)) && (H_cnt >= (I_h_total-1'b1)))
				V_cnt <= 12'd0;
			else if(H_cnt >= (I_h_total-1'b1))
				V_cnt <=  V_cnt + 1'b1;
			else
				V_cnt <= V_cnt;
		end
end

//-------------------------------------------------------------    
always @(posedge I_pxl_clk or negedge I_rst_n)
begin
	if(!I_rst_n)
		H_cnt <=  12'd0; 
	else if(H_cnt >= (I_h_total-1'b1))
		H_cnt <=  12'd0 ; 
	else 
		H_cnt <=  H_cnt + 1'b1 ;           
end

//-------------------------------------------------------------
assign  Pout_de_w = ((H_cnt>=(I_h_sync+I_h_bporch))&(H_cnt<=(I_h_sync+I_h_bporch+I_h_res-1'b1)))&
                    ((V_cnt>=(I_v_sync+I_v_bporch))&(V_cnt<=(I_v_sync+I_v_bporch+I_v_res-1'b1))) ;
assign  Pout_hs_w =  ~((H_cnt>=12'd0) & (H_cnt<=(I_h_sync-1'b1))) ;
assign  Pout_vs_w =  ~((V_cnt>=12'd0) & (V_cnt<=(I_v_sync-1'b1))) ;  

//-------------------------------------------------------------
always@(posedge I_pxl_clk or negedge I_rst_n)
begin
	if(!I_rst_n)
		begin
			Pout_de_dn  <= {N{1'b0}};                          
			Pout_hs_dn  <= {N{1'b1}};
			Pout_vs_dn  <= {N{1'b1}}; 
		end
	else 
		begin
			Pout_de_dn  <= {Pout_de_dn[N-2:0],Pout_de_w};                          
			Pout_hs_dn  <= {Pout_hs_dn[N-2:0],Pout_hs_w};
			Pout_vs_dn  <= {Pout_vs_dn[N-2:0],Pout_vs_w}; 
		end
end

assign O_de = Pout_de_dn[4];//ע�������ݶ���

always@(posedge I_pxl_clk or negedge I_rst_n)
begin
	if(!I_rst_n)
		begin                        
			O_hs  <= 1'b1;
			O_vs  <= 1'b1; 
		end
	else 
		begin                         
			O_hs  <= I_hs_pol ? ~Pout_hs_dn[3] : Pout_hs_dn[3] ;
			O_vs  <= I_vs_pol ? ~Pout_vs_dn[3] : Pout_vs_dn[3] ;
		end
end

//=================================================================================
//Test Pattern
assign De_pos	= !Pout_de_dn[1] & Pout_de_dn[0]; //de rising edge
assign De_neg	= Pout_de_dn[1] && !Pout_de_dn[0];//de falling edge
assign Vs_pos	= !Pout_vs_dn[1] && Pout_vs_dn[0];//vs rising edge

always @(posedge I_pxl_clk or negedge I_rst_n)
begin
	if(!I_rst_n)
		De_hcnt <= 12'd0;
	else if (De_pos == 1'b1)
		De_hcnt <= 12'd0;
	else if (Pout_de_dn[1] == 1'b1)
		De_hcnt <= De_hcnt + 1'b1;
	else
		De_hcnt <= De_hcnt;
end

always @(posedge I_pxl_clk or negedge I_rst_n)
begin
	if(!I_rst_n) 
		De_vcnt <= 12'd0;
	else if (Vs_pos == 1'b1)
		De_vcnt <= 12'd0;
	else if (De_neg == 1'b1)
		De_vcnt <= De_vcnt + 1'b1;
	else
		De_vcnt <= De_vcnt;
end


//---------------------------------------------------

// 1280x750

// buffer = 32x32
// each buffer pixel is 23 display pixels


reg    [ 4:0] scale      =  5'd22;
reg    [ 9:0] px_limit   = 10'd704;

reg    [23:0] color      = 24'd0;
reg           on_screen  =  1'd0;

reg    [ 4:0] buffer_v   =  5'd0;
reg    [ 4:0] buffer_h   =  5'd12;
reg    [11:0] v_offset   = 12'd0 + scale;
reg    [11:0] h_offset   = 12'd0 + scale;
reg           v_trig     =  1'd0;
reg           h_trig     =  1'd0;

reg    [ 7:0] dsp_addr   =  8'd0;
reg    [ 7:0] bit_addr   =  8'd0;
reg    [ 9:0] dsp_shft   = 10'd542;


always @(posedge I_pxl_clk or negedge I_rst_n)
begin
    if(!I_rst_n)
        on_screen = 1'd0;
    else if (De_vcnt < px_limit && De_hcnt < px_limit)
        on_screen = 1'd1;
    else
        on_screen = 1'd0;
end

always @(posedge I_pxl_clk or negedge I_rst_n)
begin

    if(!I_rst_n)
        begin
            buffer_h    <=   5'd0;
            h_trig      <=   1'd0;
            h_offset    <=  12'd0  + scale;
        end
    else if((De_hcnt == h_offset) && (Pout_de_dn[1] == 1'b1) && on_screen)
        begin
            buffer_h    <=  buffer_h + 1'd1;
            h_offset    <=  h_offset + scale;
            h_trig      <=  1'd1;
        end
    else if(De_hcnt > px_limit)
        begin
            h_offset    <=  12'd0 + scale;
            buffer_h    <=  5'd0;
        end
    else
        begin
            h_trig      <= 1'd0;
        end
end

always @(posedge I_pxl_clk or negedge I_rst_n)
begin

    if(!I_rst_n)
        begin
            buffer_v    <=   5'd0;
            v_trig      <=   1'd0;
            v_offset    <=  12'd0 + scale;
        end
    else if((De_vcnt == v_offset) && (Pout_de_dn[1] == 1'b1) && on_screen)
        begin
            buffer_v    <=  buffer_v + 1'd1;
            v_offset    <=  v_offset + scale;
            v_trig      <=  1'd1;
        end
    else if(De_vcnt > px_limit)
        begin
            v_offset    <=  12'd0 + scale;
            buffer_v    <=  5'd0;
        end
    else
        begin
            v_trig      <= 1'd0;
        end
end


always @(posedge I_pxl_clk or negedge I_rst_n)
begin
	if(!I_rst_n)
        color <= 24'd0;
	else if(Pout_de_dn[2] == 1'b1)
        if((h_trig || v_trig) && on_screen)
            color   <= BLACK;
		else if(buffer[buffer_v][5'd31 - buffer_h] && on_screen)
            color   <=  LMPON;
        else if(on_screen)
            color   <=  LMPOFF;
        else if(De_hcnt > (px_limit + dsp_shft) && De_hcnt < (px_limit + dsp_shft) + 6'd33)
            begin
                dsp_addr    =   (De_vcnt - px_limit) >> 1;
                bit_addr    =   ((px_limit + dsp_shft) - De_hcnt) >> 2;
                if(De_vcnt < 6'd32 ) // && De_vcnt > 0)
                    begin
                        if(mem[dsp_addr][bit_addr])
                            color <= GREEN;
                        else
                            color <= RED;
                    end
                else if(De_vcnt > 6'd34 && De_vcnt< 10'd547)
                    begin
                        if(ram[dsp_addr + 33][bit_addr])
                            color <= GREEN;
                        else
                            color <= RED;
                    end
                else
                    color <= BLACK;
            end
        else if(((De_hcnt > (px_limit + dsp_shft) + 5'd34) && (De_hcnt < (px_limit + dsp_shft) + 5'd38) && (De_vcnt < 10'd547)))
            begin
                if(De_vcnt[1])
                    color   <=  24'b011111110111111101111111;
                else
                    color   <=  24'b000000110000001100000011;
            end
        else
            color <= BLACK;
	else
		color	<=	BLACK  ;
end

assign O_data_r = color[ 7: 0];
assign O_data_g = color[15: 8];
assign O_data_b = color[23:16];

endmodule       
              