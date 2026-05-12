module Checker (
    input        HCLK,
    input        HRESET,
    input        HREADY_DUV,       // Ready signal from DUT
    input [31:0] HRDATA_DUV,       // Read data from DUT
    input        HREADY_GOLDEN,    // Ready signal from Golden Model
    input [31:0] HRDATA_GOLDEN,    // Read data from Golden Model
    input        HWRITE,           // Write signal
    input [31:0] HADDR,            // Address
    input [31:0] HWDATA,           // Write data
    output reg   error_flag        // Error flag
);

    integer file; // File handle

    // Open the file for writing at the start of simulation
    initial begin
        file = $fopen("checker_results.txt", "w");
        if (!file) begin
            $display("Error: Unable to open file for writing.");
            $stop;
        end
    end

    // Checker logic
    always @(posedge HCLK or posedge HRESET) begin
        if (HRESET) begin
            error_flag <= 1'b0;
        end else if (HREADY_DUV && HREADY_GOLDEN) begin
            if (HRDATA_DUV !== HRDATA_GOLDEN) begin
                error_flag <= 1'b1;
                $fwrite(file, "Mismatch at time %0t: Address: %h, Expected: %h, DUT: %h\n",
                        $time, HADDR, HRDATA_GOLDEN, HRDATA_DUV);
            end else begin
                $fwrite(file, "Match at time %0t: Address: %h, Data: %h\n",
                        $time, HADDR, HRDATA_DUV);
                 error_flag <= 1'b0;
            end
        end
    end
     // Close the file at the end of simulation
    final begin
        $fclose(file);
    end

endmodule
