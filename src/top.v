module top(

    // video stuff
    input             I_clk           , //27Mhz
    input             I_rst_n         ,
    output     [3:0]  O_led           , 
    output            O_tmds_clk_p    ,
    output            O_tmds_clk_n    ,
    output     [2:0]  O_tmds_data_p   ,//{r,g,b}
    output     [2:0]  O_tmds_data_n   ,

    // cpu stuff
    output            clk_out
    
);

wire   [31:0] screenBuffer[0:31];
wire          cpu_clk;
wire   [ 7:0] ram [0:255];
wire   [ 7:0] mem [0: 15];

assign clk_out = cpu_clk;

video_top hdmi4 (
    .I_buffer      (screenBuffer)    ,// 32x32 pixel buffer
    .I_clk         (I_clk)           , //27Mhz
    .I_rst_n       (I_rst_n)         ,
    .O_led         (O_led)           , 
    .O_tmds_clk_p  (O_tmds_clk_p)    ,
    .O_tmds_clk_n  (O_tmds_clk_n)    ,
    .O_tmds_data_p (O_tmds_data_p)   ,//{r,g,b}
    .O_tmds_data_n (O_tmds_data_n)   ,

    .ram(ram),
    .mem(mem)


);

clock cpuClk(
    .clk(I_clk),
    .out(cpu_clk)
);

cpu cpu(
    .clkin(cpu_clk),
    .buffer(screenBuffer),
    .o_ram(ram),
    .o_mem(mem)
);

endmodule