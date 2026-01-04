module cpu(
    input   wire        clkin,
    output  reg  [31:0] buffer [0:31],
    output       [ 7:0] o_ram  [0:255],
    output       [ 7:0] o_mem  [0:15]
);

    reg                 bufferScreen = 1'd0;
    reg         [31:0]  screenBuffer[0:31];

// instruction details
    reg         [15:0]  thisInstr   =   9'b0;
    reg         [3:0]   instr       =   4'b0;
    reg         [3:0]   argA        =   4'b0;
    reg         [3:0]   argB        =   4'b0;
    reg         [3:0]   argC        =   4'b0;
    reg         [7:0]   imm         =   8'b0;
    reg         [9:0]   addr        =   10'b0;
    reg         [1:0]   cond        =   2'b0;

// memory
    reg         [7:0]   mem[0:15];              // cpu cache:       sixteeen 8-bit blocks
    reg         [9:0]   callStack[0:15];        // call stack:      depth of 16
    reg         [7:0]   ram[0:255];             // memory:          256 8-bit blocks
    reg         [15:0]  instructions[0:1023];   // instruction ROM: 1024 16-bit blocks

// other
    reg signed  [9:0]   pc      =  10'd0;
    reg                 halt    =   1'd0;
    reg         [1:0]   flags   =   2'd0; // flags[0] = zero flag, flags[1] = carry flag
    reg         [8:0]   aluOut  =   9'd0;
    reg         [3:0]   ca      =   4'd0;


// clock

//reg signed [4:0] tmp_buffer_addr = 5'd0;

reg started = 1'd0;

always @(posedge started) begin




    // test instructions go here:


//    instructions[ 0] = 16'b1000000111110010;
//    instructions[ 1] = 16'b1000001011110011;
//    instructions[ 2] = 16'b1000001111110101;
//    instructions[ 3] = 16'b1000010011110110;
//    instructions[ 4] = 16'b1000010111111111;
//    instructions[ 5] = 16'b1000011000000000;
//    instructions[ 6] = 16'b1000011100000001;
//    instructions[ 7] = 16'b1000100011110000;
//    instructions[ 8] = 16'b1000100111110001;
//    instructions[ 9] = 16'b0010010101110101;
//    instructions[10] = 16'b1111100001010000;
//    instructions[11] = 16'b1111100101100000;
//    instructions[12] = 16'b1111000100000000;
//    instructions[13] = 16'b1111001100000000;
//    instructions[14] = 16'b0011010110100000;
//    instructions[15] = 16'b1011010000001001;
//    instructions[16] = 16'b0010011001110110;
//    instructions[17] = 16'b1000010111111111;
//    instructions[18] = 16'b1010000000001001;

    instructions[ 0] = 16'b1000000111110010; // ldi r 1 242
    instructions[ 1] = 16'b1000001011110011; // ldi r 2 243
    instructions[ 2] = 16'b1000001111110101; // ldi r 3 245
    instructions[ 3] = 16'b1000010011110110; // ldi r 4 246
    instructions[ 4] = 16'b1000010111111111; // ldi r 5 255
    instructions[ 5] = 16'b1000011000000000; // ldi r 6   0
    instructions[ 6] = 16'b1000011100000001; // ldi r 7   1
    instructions[ 7] = 16'b1000100011110000; // ldi r 8 240
    instructions[ 8] = 16'b1000100111110001; // ldi r 9 241
    instructions[ 9] = 16'b1000101000100000; // ldi r10  32
    instructions[10] = 16'b1111010000000000; // str r 4 r 0 
    instructions[11] = 16'b1111001100000000; // str r 3 r 0
    instructions[12] = 16'b0010010101110101; // add r 5 r 7 r 5
    instructions[13] = 16'b1111100001010000; // str
    instructions[14] = 16'b1111100101100000; // str
    instructions[15] = 16'b1111000100000000; // str
    instructions[16] = 16'b1111001100000000; // str
    instructions[17] = 16'b0011010110100000; // sub
    instructions[18] = 16'b1011010000001100; // brh
    instructions[19] = 16'b0010011001110110; // add
    instructions[20] = 16'b1000010111111111; // ldi
    instructions[21] = 16'b0011011010100000; // sub
    instructions[22] = 16'b1011000000000000; // brh
    instructions[23] = 16'b1010000000001100; // jmp

//instructions[ 0] = 16'b1000000000000000;
//instructions[ 1] = 16'b1000000100000001;
//instructions[ 2] = 16'b1000001000000010;
//instructions[ 3] = 16'b1000001100000011;
//instructions[ 4] = 16'b1000010000000100;
//instructions[ 5] = 16'b1000010100000101;
//instructions[ 6] = 16'b1000011000000110;
//instructions[ 7] = 16'b1000011100000111;
//instructions[ 8] = 16'b1000100000001000;
//instructions[ 9] = 16'b1000100100001001;
//instructions[10] = 16'b1000101000001010;
//instructions[11] = 16'b1000101100001011;
//instructions[12] = 16'b1000110000001100;
//instructions[13] = 16'b1000110100001101;
//instructions[14] = 16'b1000111000001110;
//instructions[15] = 16'b1000111100001111;

end

always @(posedge clkin) begin

    started = 1'd1;

//    screenBuffer[tmp_buffer_addr] <= screenBuffer[tmp_buffer_addr] + 1'd1;

//    if(screenBuffer[tmp_buffer_addr] == 5'd31)
//        tmp_buffer_addr <= tmp_buffer_addr + 1'd1;

    if(!halt)begin

        bufferScreen = 1'b0;

        // fetch and decode next instrucion
        thisInstr   = instructions[pc];
        instr       = thisInstr >> 12;
        cond        = thisInstr >> 10;
        argA        = thisInstr >> 8;
        argB        = thisInstr >> 4;
        argC        = thisInstr;
        imm         = thisInstr;
        addr        = thisInstr;

     // 100000000000
     // 100000000000
     // 100000000000


        // execute instruction
        case(instr)
            // NOP
            4'b0000:    begin

                            // increment program counter
                            pc  <=   pc + 1;
                        end
            // HLT
            4'b0001:    begin

                            // stop the program
                            halt    <=  1'b1;
                        end
            // ADD
            4'b0010:    begin
                            // perform arithmetic
                            aluOut      =  mem[argA] + mem[argB];

                            // write to cache
                            mem[argC]   <=  aluOut;
            
                            // set flags
                            if(aluOut == 5'b0)  flags[0] <= 1;
                                else            flags[0] <= 0;

                            if(aluOut >> 4)     flags[1] <= 1;
                                else            flags[1] <= 0;

                            // incrament program counter
                            pc  <=  pc + 1;
                        end
            // SUB
            4'b0011:    begin
                            // perform arithmetic
                            aluOut      =  mem[argA] - mem[argB];

                            // write to cache
                            mem[argC]   <=  aluOut;
            
                            // set flags
                            if(aluOut == 5'b0)  flags[0] <= 1;
                                else            flags[0] <= 0;

                            if(aluOut >> 4)     flags[1] <= 1;
                                else            flags[1] <= 0;

                            // incrament program counter
                            pc  <=  pc + 1;

                        end
            // NOR
            4'b0100:    begin
                            // perform bitwise logic
                            aluOut      = ~(mem[argA] | ~mem[argB]);

                            // write to cache
                            mem[argC]   =  aluOut;
            
                            // set flags
                            if(aluOut == 5'b0)  flags[0] = 1;
                                else            flags[0] = 0;

                            if(aluOut >> 4)     flags[1] = 1;
                                else            flags[1] = 0;

                            // incrament program counter
                            pc  <=  pc + 1;

                        end
            // AND
            4'b0101:    begin
                            // perform bitwise logic
                            aluOut      =  mem[argA] & mem[argB];

                            // write to cache
                            mem[argC]   <=  aluOut;
            
                            // set flags
                            if(aluOut == 5'b0)  flags[0] <= 1;
                                else            flags[0] <= 0;

                            if(aluOut >> 4)     flags[1] <= 1;
                                else            flags[1] <= 0;

                            // incrament program counter
                            pc  <=  pc + 1;

                        end
            // XOR
            4'b0110:    begin
                            // perform bitwise logic
                            aluOut      =  mem[argA] ^ mem[argB];

                            // write to cache
                            mem[argC]   <=  aluOut;
            
                            // set flags
                            if(aluOut == 5'b0)  flags[0] <= 1;
                                else            flags[0] <= 0;

                            if(aluOut >> 4)     flags[1] <= 1;
                                else            flags[1] <= 0;

                            // incrament program counter
                            pc  <=  pc + 1;

                        end
            // RSH
            4'b0111:    begin
                            // perform bitwise logic
                            aluOut      =  mem[argA] >> 1;

                            // write to cache
                            mem[argC]   <=  aluOut;
            
                            // set flags
                            if(aluOut == 5'b0)  flags[0] <= 1;
                                else            flags[0] <= 0;

                            if(aluOut >> 4)     flags[1] <= 1;
                                else            flags[1] <= 0;

                            // incrament program counter
                            pc  <=  pc + 1;

                        end
            // LDI
            4'b1000:    begin
                            // write to cache
                            mem[argA]   <=  imm;

                            // incrament program counter
                            pc  <=  pc + 1;

                        end
            // ADI
            4'b1001:    begin
                            // perform arithmetic
                            aluOut      =  mem[argA] + imm;

                            // write to cache
                            mem[argA]   <=  aluOut;
            
                            // set flags
                            if(aluOut == 5'b0)  flags[0] <= 1;
                                else            flags[0] <= 0;

                            if(aluOut >> 4)     flags[1] <= 1;
                                else            flags[1] <= 0;

                            // incrament program counter
                            pc  <=  pc + 1;

                        end
            // JMP
            4'b1010:    begin
                            // set program counter to specified address
                            pc  <=  addr;

                        end
            // BRH
            4'b1011:    begin
                            // if conditions met, set program counter to specified address. otherwise increment as normal
                            if(flags == cond)   pc  <=  addr;
                                else            pc  <=  pc + 1;

                        end
            // CAL
            4'b1100:    begin
                            // push address to callstack
                            ca  = ca + 1;
                            callStack[ca]   <=  pc + 1;
                            pc  <= addr;
                        end
            // RET
            4'b1101:    begin
                            // push address to callstack
                            pc  <= callStack[ca];
                            ca  <= ca - 1;

                        end
            // LOD
            4'b1110:    begin
                            // copy data to ram
                            mem[argB+argC]   <=   ram[argA];

                            // increment program counter
                            pc  <=   pc + 1;

                        end
            // STR
            4'b1111:    begin

                            case(argB)
                                4'd242:  screenBuffer[ram[240]][ram [241]] = 1'b1;      // write selected pixel
                                4'd243:  screenBuffer[ram[240]][ram [241]] = 1'b0;      // clear selected pixel
                                4'd245:  bufferScreen    =   1'b1;                      // buffer the screen
                                4'd243:                                                 // clear screen buffer
                                         begin
                                            screenBuffer[ 0] = 32'd0;
                                            screenBuffer[ 1] = 32'd0;
                                            screenBuffer[ 2] = 32'd0;
                                            screenBuffer[ 3] = 32'd0;
                                            screenBuffer[ 4] = 32'd0;
                                            screenBuffer[ 5] = 32'd0;
                                            screenBuffer[ 6] = 32'd0;
                                            screenBuffer[ 7] = 32'd0;
                                            screenBuffer[ 8] = 32'd0;
                                            screenBuffer[ 9] = 32'd0;
                                            screenBuffer[10] = 32'd0;
                                            screenBuffer[11] = 32'd0;
                                            screenBuffer[12] = 32'd0;
                                            screenBuffer[13] = 32'd0;
                                            screenBuffer[14] = 32'd0;
                                            screenBuffer[15] = 32'd0;
                                            screenBuffer[16] = 32'd0;
                                            screenBuffer[17] = 32'd0;
                                            screenBuffer[18] = 32'd0;
                                            screenBuffer[19] = 32'd0;
                                            screenBuffer[20] = 32'd0;
                                            screenBuffer[21] = 32'd0;
                                            screenBuffer[22] = 32'd0;
                                            screenBuffer[23] = 32'd0;
                                            screenBuffer[24] = 32'd0;
                                            screenBuffer[25] = 32'd0;
                                            screenBuffer[26] = 32'd0;
                                            screenBuffer[27] = 32'd0;
                                            screenBuffer[28] = 32'd0;
                                            screenBuffer[29] = 32'd0;
                                            screenBuffer[30] = 32'd0;
                                            screenBuffer[31] = 32'd0;
                                         end
                                default: ram[argA] = mem[argB+argC];                 // load data to ram
                            endcase

                            // increment program counter
                            pc  =   pc + 1;

                        end
            // NOP  
            default:    pc  =   pc + 1; // increment program counter

        endcase

        mem[0]  <=   8'b0;
        
    end else
        started = 1'd0;
end

always @(posedge bufferScreen)
begin

    buffer <= screenBuffer;

end

assign o_ram = ram;
assign o_mem = mem;


endmodule