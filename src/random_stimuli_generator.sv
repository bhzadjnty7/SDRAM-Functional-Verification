module sdram_top_tb2();

    // Testbench signals
    reg        tb_HCLK;
    reg        tb_HRESET;
    reg        tb_HWRITE;
    reg        tb_HSEL;
    reg [31:0] tb_HWDATA;
    reg [31:0] tb_HADDR;
    
    wire        tb_HREADY;
    wire [31:0] tb_HRDATA;

    integer     file; // File handle for logging

    wire [31:0] golden_HRDATA;
    wire golden_HREADY;

    // Checker output signals
    wire error_flag;
   // scoreboard output signals
    wire [31:0] total_transaction;
    wire [31:0] write_transaction;
    wire [31:0] read_transaction;
    wire [31:0] invalid_transaction;

    integer i;
    
    // Instance of design under test
    sdram_top DUT (
        .in_HCLK(tb_HCLK),
        .in_HRESET(tb_HRESET),
        .in_HWRITE(tb_HWRITE),
        .in_HSEL(tb_HSEL),
        .in_HWDATA(tb_HWDATA),
        .in_HADDR(tb_HADDR),
        .out_HREADY(tb_HREADY),
        .out_HRDATA(tb_HRDATA)
    );

    // golden model Instantiation
    Golden_Model_sdram Golden_Model(
            .HCLK(tb_HCLK),
            .HRESET(tb_HRESET),
            .HWRITE(tb_HWRITE),
            .HSEL(tb_HSEL),
            .HWDATA(tb_HWDATA),
            .HADDR(tb_HADDR),
            .HREADY(golden_HREADY),
            .HRDATA(golden_HRDATA)
    );

    
    // Checker Instantiation
    Checker checker_inst (
        .HCLK(tb_HCLK),
        .HRESET(tb_HRESET),
        .HRDATA_DUV(tb_HRDATA),
        .HRDATA_GOLDEN(golden_HRDATA),
        .HREADY_DUV(tb_HREADY),
        .HREADY_GOLDEN(golden_HREADY),
        .HWRITE(tb_HWRITE),
        .HADDR(tb_HADDR),
        .HWDATA(tb_HWDATA),
        .error_flag(error_flag)
    );
    
    // Instantiate Scoreboard
    sdram_scoreboard scoreboard(
       .in_HCLK(tb_HCLK),
       .in_HRESET(tb_HRESET),
       .in_HWRITE(tb_HWRITE),     // Write Enable
       .in_HSEL(tb_HSEL),       // Select Signal
       .in_HADDR(tb_HADDR),      // Address
       .in_HWDATA(tb_HWDATA),     // Write Data
       .out_HREADY(tb_HREADY),    // Ready Signal
       .out_HRDATA(tb_HRDATA),    // Read Data
       .total_transactions(total_transaction), // Total transactions (read + write + invalid)
       .read_transactions(read_transaction),  // Total read transactions
       .write_transactions(write_transaction), // Total write transactions
       .invalid_transactions(invalid_transaction)
    );

  functional_coverage fcov (
      .tb_HCLK(tb_HCLK),
      .tb_HRESET(tb_HRESET),
      .tb_HWRITE(tb_HWRITE),
      .tb_HSEL(tb_HSEL),
      .tb_HREADY(tb_HREADY),
      .tb_HWDATA(tb_HWDATA),
      .tb_HRDATA(tb_HRDATA),
      .tb_HADDR (tb_HADDR)
  );
  
   //instanciate the assertion module
   sdram_assertions assertions(
          .tb_HCLK(tb_HCLK),
          .tb_HRESET(tb_HRESET),
          .tb_HWRITE(tb_HWRITE),
          .tb_HSEL(tb_HSEL),
          .tb_HWDATA(tb_HWDATA),
          .tb_HADDR(tb_HADDR),
          .tb_HREADY(tb_HREADY),
          .tb_HRDATA(tb_HRDATA)
   );   
   
    // Function to generate a 32-bit address
    function [31:0] generate_address(
        input [4:0] invalid_bits,        // 5 bits for invalid
        input [8:0] column_address,      // 9 bits for column address
        input [1:0] bank_select,         // 2 bits for bank select
        input [13:0] row_address         // 14 bits for row address
     );
        begin
             generate_address = {2'b10,   // Memory map I/O fixed to "10"
                                 invalid_bits,
                                 column_address,
                                 bank_select,
                                 row_address};
         end
    endfunction

    // task for write operation(later used in test cases)
    task write_operation(input [31:0] addr, input [31:0] data, integer file); //define a task for write operation
         begin
              $display("Starting Write Operation at time %0t", $time);
              $fwrite(file, "Starting write operation at time %0t\n", $time);
        
              @(posedge tb_HCLK);
              tb_HSEL = 1;
              tb_HWRITE = 1;    // Write = 1
              tb_HWDATA = data; // Data to write
              tb_HADDR = addr;  // Address to write to
        
              #50; // Wait for write operation to complete
              #1;
              $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA); //define a task for read operation
           end
    endtask  
    
    // task for read operation(later used in test cases)
    task read_operation(input [31:0] addr, integer file);
         begin
             $display("Starting Read Operation at time %0t", $time);
             $fwrite(file, "Starting read operation at time %0t\n", $time);
        
             @(posedge tb_HCLK);
             tb_HSEL = 1;
             tb_HWRITE = 0;  // Read = 1
             tb_HADDR = addr; // Address to read from
        
             #50; // Wait for read operation to complete
             #1;
             $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);
          end
    endtask 


    // Clock generation
    initial begin
        tb_HCLK = 0;
        forever #5 tb_HCLK = ~tb_HCLK;
    end

    // stimulus
    initial begin
        
        // Set a seed for reproducibility
        integer seed = 12345; // You can change this to any integer
        reg [4:0] invalid_bits;
        reg [8:0] column_address;
        reg [1:0] bank_select;
        reg [13:0] row_address;
        
        // Initialize signals
        tb_HRESET = 1;
        tb_HWRITE = 0;
        tb_HSEL = 0;
        tb_HWDATA = 32'h0;
        tb_HADDR = 32'h0;
         
        // Reset period
        #100;
        tb_HRESET = 0;
        #20;

        file = $fopen("randomstimuli_output.txt", "w");
        
        //senario1: Random read/write operations
        $fwrite(file,"senario 1: random read & write to a random address: %0t\n",$time);
        for ( i = 0; i < 10; i++) begin
            // Generate random components for the address using a seed
            //invalid_bits = $random(seed);
            // column_address = $random(seed);
            // bank_select = $random(seed);
            // row_address = $random(seed);
            tb_HWDATA = $random(seed);

            // Constrain the address to be within 0x80000000 to 0xBFFFFFFF
            tb_HADDR = $urandom_range(32'h80000000,32'hBFFFFFFF);

            // Perform a random write operation
            write_operation(tb_HADDR, tb_HWDATA, file);

            // Perform a random read operation
            read_operation(tb_HADDR, file);
        end
        //senario2: write and from an address with random row
        $fwrite(file,"senario 2: write and from an address with random row: %0t\n",$time);
        row_address = $random(seed);
        tb_HADDR = generate_address(5'b00000,9'b000000000,2'b00,row_address);

        write_operation(tb_HADDR,32'hDEADBEEF,file);
        read_operation(tb_HADDR,file);
        
        //senario3: write and read from 4 col's in a row
        $fwrite(file,"senario3: Test write random data to 4 col's in a row: %0t\n",$time);
        for (i = 0; i < 4; i++) begin
             tb_HADDR = generate_address(5'b00000,i,2'b01,14'b00000000000000);
             tb_HWDATA=$random(seed); 
             write_operation(tb_HADDR,tb_HWDATA,file);
        end
        
        for (i = 0; i < 4; i++) begin
             tb_HADDR = generate_address(5'b00000,i,2'b01,14'b00000000000000);
             read_operation(tb_HADDR,file);
        end

        //senario 4: use random task to write or read
        $fwrite(file,"Test random read and write using task with urandom_range: %0t\n",$time);
        for (i=0;i<7;i++) begin
             tb_HADDR = $urandom_range(32'h80000000,32'hB0000000);
             tb_HWDATA= $urandom_range(32'h00000000,32'hFFFFFFFF);
             write_operation(tb_HADDR,tb_HWDATA,file);
             read_operation(tb_HADDR,file);
        end
        //additional test cases in order to improve coverage report
        //senario 5: invalid HWRITE signal value
        $fwrite(file,"senario 5: test invalid HWRITE signal during write operation: %0t\n",$time);
        $fwrite(file,"start write operation: %0t\n",$time);
        @(posedge tb_HCLK);
        tb_HSEL = 1;
        tb_HWRITE = 1'bx;    // Write = 1
        tb_HWDATA = $urandom_range(32'h00000000,32'hFFFFFFFF); // Data to write
        tb_HADDR = $urandom_range(32'h80000000,32'hBFFFFFFF);  // Address to write to
        
        #50; // Wait for write operation to complete
        #1;
        $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);
        $fwrite(file,"start read operation: %0t\n",$time);
        @(posedge tb_HCLK);
        tb_HSEL = 1;
        tb_HWRITE = 0;    // read operation
        tb_HWDATA = $urandom_range(32'h00000000,32'hFFFFFFFF); // Data to write
        tb_HADDR = tb_HADDR;  // Address to write to
        
        #50; // Wait for write operation to complete
        #1;
        $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);

        //senario 6: invalid HSEL signal value
        $fwrite(file,"senario 6: test invalid HWRITE signal during write operation: %0t\n",$time);
        $fwrite(file,"start write operation: %0t\n",$time);
        @(posedge tb_HCLK);
        tb_HSEL = 1'bx;
        tb_HWRITE = 1'b1;    // Write = 1
        tb_HWDATA = $urandom_range(32'h00000000,32'hFFFFFFFF); // Data to write
        tb_HADDR = $urandom_range(32'h80000000,32'hBFFFFFFF);  // Address to write to
        
        #50; // Wait for write operation to complete
        #1;
        $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);
        $fwrite(file,"start read operation: %0t\n",$time);
        @(posedge tb_HCLK);
        tb_HSEL = 1;
        tb_HWRITE = 0;    // read operation
        tb_HADDR = tb_HADDR;  // Address to read from
        
        #50; // Wait for write operation to complete
        #1;
        $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);

        //senario 7: invalid HWRITE & HSEL signals
        $fwrite(file,"senario 7: invalid HWRITE & HSEL: %0t\n",$time);
        $fwrite(file,"start invalid operation: %0t\n",$time);
        @(posedge tb_HCLK);
        tb_HSEL = 1'bx;
        tb_HWRITE = 1'bx;    // Write = 1
        tb_HWDATA = $urandom_range(32'h00000000,32'hFFFFFFFF); // Data to write
        tb_HADDR = $urandom_range(32'h80000000,32'hBFFFFFFF);  // Address to write to
        
        #50; // Wait for write operation to complete
        #1;
        $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);

        $fwrite(file,"start invalid operation: %0t\n",$time);
        @(posedge tb_HCLK);
        tb_HSEL = 1'bx;  // invalid HSEL signal
        tb_HWRITE = 1'bx;  // invalid HWRITE signal  
        tb_HWDATA = $urandom_range(32'h00000000,32'hFFFFFFFF); // Data to write
        tb_HADDR = tb_HADDR;  // Address to write to
        
        #50; // Wait for write operation to complete
        #1;
        $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);

        //senario 8: random reset signal during write and read operation
         $fwrite(file,"senario 8: random reset during write/read operation: %0t\n",$time);
         for(i=0;i<2;i++)begin
         $fwrite(file,"test reset during write/read operation: %0t\n",$time);
         $fwrite(file,"start write operation: %0t\n",$time);
         @(posedge tb_HCLK);
         tb_HSEL = 1;
         tb_HWRITE = 1;    // Write = 1
         tb_HWDATA = $urandom_range(32'h00000000,32'hFFFFFFFF); // Data to write
         tb_HADDR = $urandom_range(32'h80000000,32'hBFFFFFFF);  // Address to write to
        
         #30; // Wait for write operation to complete
         tb_HRESET = 1;
         #20;
         tb_HRESET = 0;
         #1;
         $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);
         $fwrite(file,"start read operation: %0t\n",$time);
         @(posedge tb_HCLK);
         tb_HSEL = 1;
         tb_HWRITE = 0;    // read operation
         tb_HADDR = tb_HADDR;  // Address to write to
        
         #30; // Wait for write operation to complete
         tb_HRESET = 1;
         #20;
         tb_HRESET = 0;
         #1;
         $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);
         
         end

         //senario 9: testing reset on different time sequences in order to improve coverage report
         for(i=0;i<2;i++)begin
         $fwrite(file,"senario 9: test reset during write/read operation different time sequences: %0t\n",$time);
         $fwrite(file,"start write operation: %0t\n",$time);
         @(posedge tb_HCLK);
         tb_HSEL = 1;
         tb_HWRITE = 1;    // Write = 1
         tb_HWDATA = $urandom_range(32'h00000000,32'hFFFFFFFF); // Data to write
         tb_HADDR = $urandom_range(32'h80000000,32'hBFFFFFFF);  // Address to write to
        
         #10; // Wait for write operation to complete
         tb_HRESET = 1;
         #40;
         tb_HRESET = 0;
         #1;
         $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);
         $fwrite(file,"start read operation: %0t\n",$time);
         @(posedge tb_HCLK);
         tb_HSEL = 1;
         tb_HWRITE = 0;    // read operation
         tb_HADDR = tb_HADDR;  // Address to write to
        
         #10; // Wait for write operation to complete
         tb_HRESET = 1;
         #40;
         tb_HRESET = 0;
         #1;
         $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);
         
         end

         //senario 10: testing HSEL = 0;
         $fwrite(file,"senario 10: test HSEL=0 during write/read different time sequences: %0t\n",$time);
         $fwrite(file,"start write operation: %0t\n",$time);
         @(posedge tb_HCLK);
         tb_HSEL = 0;
         tb_HWRITE = 1;    // Write = 1
         tb_HWDATA = $urandom_range(32'h00000000,32'hFFFFFFFF); // Data to write
         tb_HADDR = $urandom_range(32'h80000000,32'hBFFFFFFF);  // Address to write to
        
         #50;
         #1;
         $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);
         $fwrite(file,"start read operation: %0t\n",$time);
         @(posedge tb_HCLK);
         tb_HSEL = 0;
         tb_HWRITE = 0;    // read operation
         tb_HADDR = tb_HADDR;  // Address to write to
              
         #50;
         #1;
         $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);

         //senario 11: testing HSEL = 0/ HWDATA = 0;
         $fwrite(file,"senario 11: test HSEL=0 during write/read different time sequences: %0t\n",$time);
         $fwrite(file,"start write operation: %0t\n",$time);
         @(posedge tb_HCLK);
         tb_HSEL = 0;
         tb_HWRITE = 1'bx;    // Write = 1
         tb_HWDATA = $urandom_range(32'h00000000,32'hFFFFFFFF); // Data to write
         tb_HADDR = $urandom_range(32'h80000000,32'hBFFFFFFF);  // Address to write to
        
         #50;
         #1;
         $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);
         $fwrite(file,"start read operation: %0t\n",$time);
         @(posedge tb_HCLK);
         tb_HSEL = 1'bx;
         tb_HWRITE = 0;    // read operation
         tb_HADDR = tb_HADDR;  // Address to write to
              
         #50;
         #1;
        $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);

        //senario 12: test invalid bank in order to improve coverage report
        $fwrite(file,"senario 12: Test invalid bank select value: %0t\n", $time);
        invalid_bits = $random(seed);
        column_address = $random(seed);
        bank_select = $random(seed);
        row_address = $random(seed);
        tb_HWDATA = $random(seed);
        $fwrite(file,"start write operation: %0t\n", $time);
        tb_HADDR = generate_address(invalid_bits,column_address,2'bxx,row_address);
        write_operation(tb_HADDR, tb_HWDATA, file);
        read_operation(tb_HADDR, file);

        // additional reset test cases in order to cover all transition states
        //senario 13: testing reset on different time sequences in order to improve coverage report
        for(i=0;i<2;i++)begin
     	   $fwrite(file,"senario 13: test reset during write/read operation different time sequences: %0t\n",$time);
     	   $fwrite(file,"start write operation: %0t\n",$time);
     	   @(posedge tb_HCLK);
     	   tb_HSEL = 1;
     	   tb_HWRITE = 1;    // Write = 1
     	   tb_HWDATA = $urandom_range(32'h00000000,32'hFFFFFFFF); // Data to write
     	   tb_HADDR = $urandom_range(32'h80000000,32'hBFFFFFFF);  // Address to write to
        
     	   #40
     	   tb_HRESET = 1;
     	   #10;
     	   tb_HRESET = 0;
     	   #1;
           $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);
      	   $fwrite(file,"start read operation: %0t\n",$time);
      	   @(posedge tb_HCLK);
      	   tb_HSEL = 1;
      	   tb_HWRITE = 0;    // read operation
           tb_HADDR = tb_HADDR;  // Address to write to
      	        
     	   #40; // Wait for write operation to complete
      	   tb_HRESET = 1;
           #10;
           tb_HRESET = 0;
           #1;
           $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);
         
           end
        
           // senario 14: fully randomized opeartion
     	   for(i=0;i<9;i++)begin
               $fwrite(file,"senario 14: fully randomized operation: %0t\n",$time);
               @(posedge tb_HCLK);
    	       tb_HSEL = $random(seed)%2;
               tb_HWRITE = $random(seed)%2;    // Write = 1
               tb_HWDATA = $urandom_range(32'h00000000,32'hFFFFFFFF); // Data to write
               tb_HADDR = $urandom_range(32'h80000000,32'hBFFFFFFF);  // Address to write to
        
               #10
               tb_HRESET = $random(seed)%2;
               #10;
               tb_HRESET = $random(seed)%2;
               #10;
               tb_HRESET = $random(seed)%2;
               #10;
               tb_HRESET = $random(seed)%2;
               #10;
               #1;
               $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);
           end

           //senario 15: new scenario to cover all conditions on line 76 controller
           $fwrite(file,"senario 15: additional TC to cover line 76 controller: %0t\n",$time);
           for(i=0;i<10;i++)begin
              $fwrite(file,"start random operation: %0t\n",$time);
              @(posedge tb_HCLK);
              tb_HSEL = 0;
              tb_HWRITE = 1;    // Write = 1
              tb_HWDATA = $urandom_range(32'h00000000,32'hFFFFFFFF); // Data to write
              tb_HADDR = $urandom_range(32'h80000000,32'hBFFFFFFF);  // Address to write to
        
       	      #50;
       	      #1;
              $fwrite(file, "Time: %0t | tb_HREADY: %b | tb_HRDATA: %h\n", $time, tb_HREADY, tb_HRDATA);
            end
            //senario16: Test for multiple write and then read(for bug finding)
            $fwrite(file,"senario 15: multiple write to an address then read from it: %0t\n",$time);
            
            invalid_bits = $random(seed);
     	    column_address = $random(seed);
     	    bank_select = $random(seed);
     	    row_address = $random(seed);
    	    tb_HWDATA = $random(seed);

            tb_HADDR = generate_address(invalid_bits,column_address,bank_select,row_address);
            write_operation(tb_HADDR,tb_HWDATA,file);

            tb_HWDATA = $random(seed);
            write_operation(tb_HADDR,tb_HWDATA,file);
            read_operation(tb_HADDR,file);

         $display(" total_transactions: %d\n write_transactions: %d\n read_transactions: %d\n invalid_transactions: %d\n ", total_transaction , write_transaction , read_transaction , invalid_transaction); 
            
         $fclose(file);
    end
    
endmodule


