`timescale 1ns / 1ps

module Cache_tb;
    reg        clk;
    reg        reset;
    reg        access;
    reg  [31:0] Address;
    reg  [31:0] Write_Data;
    reg        Write_Enable;
    wire [31:0] Data_Out;
    wire        Hit_Miss;
    wire [31:0] total_accesses;
    wire [31:0] total_misses;

    Cache uut (
        .clk(clk),
        .reset(reset),
        .access(access),
        .Address(Address),
        .Write_Data(Write_Data),
        .Write_Enable(Write_Enable),
        .Data_Out(Data_Out),
        .Hit_Miss(Hit_Miss),
        .total_accesses(total_accesses),
        .total_misses(total_misses)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task do_access;
        input [31:0] addr;
        input        we;
        input [31:0] wdata;
        begin
            Address      = addr;
            Write_Enable = we;
            Write_Data   = wdata;
            access       = 1;
            @(posedge clk);
            access       = 0;
        end
    endtask

    initial begin
        reset = 1; access = 0; Address = 0; Write_Enable = 0; Write_Data = 0;
        repeat (2) @(posedge clk); 
        reset = 0;

        do_access(32'd12, 0, 0);
        $display("Read Addr=12: Data_Out=%h, Hit_Miss=%b, Acc=%0d, Miss=%0d", Data_Out, Hit_Miss, total_accesses, total_misses);

        do_access(32'd12, 0, 0);
        $display("Read Addr=12 again: Data_Out=%h, Hit_Miss=%b, Acc=%0d, Miss=%0d",Data_Out, Hit_Miss, total_accesses, total_misses);


        do_access(32'd20, 0, 0);
        $display("Read Addr=20: Data_Out=%h, Hit_Miss=%b, Acc=%0d, Miss=%0d", Data_Out, Hit_Miss, total_accesses, total_misses);

  

        do_access(32'd60, 1, 32'hBBBBBBBB);
        $display("Write Addr=60: Hit_Miss=%b, Acc=%0d, Miss=%0d", 
                  Hit_Miss, total_accesses, total_misses);

        do_access(32'd60, 0, 0);
        $display("Read Addr=60: Data_Out=%h, Hit_Miss=%b, Acc=%0d, Miss=%0d", Data_Out, Hit_Miss, total_accesses, total_misses);
        
 
        
         do_access(32'd256, 1, 32'hABABABA);
        $display("Write Addr=256: Hit_Miss=%b, Acc=%0d, Miss=%0d", 
                  Hit_Miss, total_accesses, total_misses);
        

        $display("Final: Accesses=%0d, Misses=%0d, HitRate=%.2f%%", 
                  total_accesses, total_misses, 
                  ((total_accesses - total_misses) * 100.0) / total_accesses);

        $finish;
    end
endmodule



