`timescale 1ns / 1ps

module Cache (  //TARIF VOOROODI HA VA KHOROOJI HA 
    input               clk,
    input               reset,
    input               access,
    input        [31:0] Address,
    input        [31:0] Write_Data,
    input               Write_Enable,
    output reg   [31:0] Data_Out,
    output reg          Hit_Miss,
    output reg   [31:0] total_accesses,
    output reg   [31:0] total_misses
);



    //TARIF PARAMETR(SABET) HA TEBGH E PDF
    parameter NUM_LINES       = 16;
    parameter WORDS_PER_LINE  = 4;
    parameter MEM_SIZE        = 1024;
    parameter TAG_BITS        = 24; 
    
    
    //TARIF REGISTER HA MESL E PDF
    reg [31:0]         Cache_Memory [0:NUM_LINES-1][0:WORDS_PER_LINE-1];
    reg [23:0]         Cache_Tags   [0:NUM_LINES-1];
    reg                Valid_bit    [0:NUM_LINES-1];
    reg [7:0]          Memory       [0:MEM_SIZE-1];

    //TARIF REG BARAYE ANJAM MOHASEBAT
    reg [TAG_BITS-1:0] TAGaddress;
    reg [3:0]          INDEXaddress;
    reg [1:0]          OFFSETWORDaddress;
    reg [31:0]         CURRaddress;
    reg                isHIT;
    
    integer i;


    //TASK BARAYE WRITE DAR MEMORY ASLI 
    task WRITE_INMEMORY;
        input [31:0] address;
        input [31:0] data;
        begin
            Memory[address]   <= data[7:0];
            Memory[address+1] <= data[15:8];
            Memory[address+2] <= data[23:16];
            Memory[address+3] <= data[31:24];
        end
    endtask



    //READ FILE
    initial begin
        $readmemb("memory.list", Memory);
    end


    //SHORO HALAT HAYE MOKHTALEF  ///READ HIT/READ MISS/WRITE HIT/WRITE MISS
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < NUM_LINES; i = i + 1) begin
                Valid_bit[i] <= 0;
                Cache_Tags[i] <= 0;
            end
            Data_Out       <= 0;
            Hit_Miss       <= 0;
            total_accesses <= 0;
            total_misses   <= 0;
        end
        else if (access) begin
            total_accesses <= total_accesses + 1;
            TAGaddress         = Address[31:8];
            INDEXaddress       = Address[7:4];
            OFFSETWORDaddress = Address[3:2];
            CURRaddress  = {Address[31:4], 4'b0};  //BEDAST AVARDAN ADDRESS AVVAL BARAYE AVARDAN E AN BLOCK BE CACHE
            isHIT = Valid_bit[INDEXaddress] && (Cache_Tags[INDEXaddress] == TAGaddress);
            Hit_Miss <= isHIT;

            if (Write_Enable) begin
                Data_Out <= Write_Data;
                if (isHIT) begin
                    Cache_Memory[INDEXaddress][OFFSETWORDaddress] <= Write_Data;
                    WRITE_INMEMORY({Address[31:2], 2'b00}, Write_Data);
                end
                else begin
                    total_misses <= total_misses + 1;
                    Valid_bit[INDEXaddress] <= 1;
                    Cache_Tags[INDEXaddress] <= TAGaddress;
                    for (i = 0; i < WORDS_PER_LINE; i = i + 1) begin
                        Cache_Memory[INDEXaddress][i] <= {
                            Memory[CURRaddress + i*4 + 3],
                            Memory[CURRaddress + i*4 + 2],
                            Memory[CURRaddress + i*4 + 1],
                            Memory[CURRaddress + i*4 + 0]
                        };
                    end
                    Cache_Memory[INDEXaddress][OFFSETWORDaddress] <= Write_Data;
                    WRITE_INMEMORY({Address[31:2], 2'b00}, Write_Data);
                end
            end
            else begin
                if (isHIT) begin
                    Data_Out <= Cache_Memory[INDEXaddress][OFFSETWORDaddress]; //TAEEN DATA KHOROOJI
                end
                else begin
                    total_misses <= total_misses + 1;
                    Valid_bit[INDEXaddress] <= 1;
                    Cache_Tags[INDEXaddress] <= TAGaddress;
                    
                    for (i = 0; i < WORDS_PER_LINE; i = i + 1) begin   //Memory BE CACHE MEMORY
                        Cache_Memory[INDEXaddress][i] <= {
                            Memory[CURRaddress + i*4 + 3],
                            Memory[CURRaddress + i*4 + 2],
                            Memory[CURRaddress + i*4 + 1],
                            Memory[CURRaddress + i*4 + 0]
                        };
                    end
                    
                    Data_Out <= {    //4BYTE POSHT E HAM GHARAR MIDE TA YEK KALAME 32 BITI BESAZE KE KALAME HA GHATI NASHAN
                        Memory[{Address[31:2], 2'b00} + 3],
                        Memory[{Address[31:2], 2'b00} + 2],
                        Memory[{Address[31:2], 2'b00} + 1],
                        Memory[{Address[31:2], 2'b00} + 0]
                    };
                end
            end
        end
    end

endmodule
