module Golden_Model_sdram(
    input        HCLK,         // Clock signal
    input        HRESET,       // Reset signal
    input        HWRITE,       // Write Enable (1 = write, 0 = read)
    input        HSEL,         // Select signal
    input [31:0] HWDATA,       // Write data
    input [31:0] HADDR,        // Address

    output reg        HREADY,  // Ready signal
    output reg [31:0] HRDATA   // Read data
);

    // SDRAM Parameters
    parameter DATA_WIDTH = 32;
    parameter ROWS = 16384;    // Number of rows (14-bit addressing)
    parameter COLUMNS = 512;  // Number of columns (9-bit addressing)
    parameter BANKS = 4;      // Number of banks (2-bit addressing)

    // SDRAM Memory Array
    reg [DATA_WIDTH-1:0] sdram_memory [0:BANKS-1][0:ROWS-1][0:COLUMNS-1];

    // Address Decoding
    reg [1:0] active_bank;
    reg [13:0] active_row;
    reg [8:0] active_column;

    // FSM States
    typedef enum logic [3:0] {
        IDLE = 4'b0000,
        READ_ACT = 4'b0001,
        READ_NOP1 = 4'b0010,
        READ_CAS = 4'b0011,
        READ_NOP2 = 4'b0100,
        READ_NOP3 = 4'b0101,
        WRITE_ACT = 4'b0110,
        WRITE_NOP1 = 4'b0111,
        WRITE_CAS = 4'b1000,
        WRITE_NOP2 = 4'b1001,
        WRITE_NOP3 = 4'b1010
    } state_t;

    state_t current_state, next_state;

    // Temporary Buffer for Read/Write Operations
    reg [31:0] data_buffer;

    // FSM Sequential Logic
    always @(posedge HCLK or posedge HRESET) begin
        if (HRESET) begin
            current_state <= IDLE;
            HREADY <= 1'b1;
        end else begin
            current_state <= next_state;
        end
    end

    // FSM Next State Logic
    always @(*) begin
        // Default next state
        next_state = current_state;
        HREADY = 1'b1;

        case (current_state)
            IDLE: begin
                if (HSEL) begin
                    if (HWRITE) begin
                        next_state = WRITE_ACT;
                        HREADY = 1'b0;
                    end else begin
                        next_state = READ_ACT;
                        HREADY = 1'b0;
                    end
                end
            end

            READ_ACT: begin
                next_state = READ_NOP1;
            end

            READ_NOP1: begin
                next_state = READ_CAS;
            end

            READ_CAS: begin
                next_state = READ_NOP2;
            end

            READ_NOP2: begin
                next_state = READ_NOP3;
            end

            READ_NOP3: begin
                next_state = IDLE;
            end

            WRITE_ACT: begin
                next_state = WRITE_NOP1;
            end

            WRITE_NOP1: begin
                next_state = WRITE_CAS;
            end

            WRITE_CAS: begin
                next_state = WRITE_NOP2;
            end

            WRITE_NOP2: begin
                next_state = WRITE_NOP3;
            end

            WRITE_NOP3: begin
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Address Decoding and Memory Access
    always @(posedge HCLK) begin
        if (HRESET) begin
            // Reset internal registers
            active_row <= 14'bx;
            active_column <= 9'bx;
            active_bank <= 2'bx;
            HRDATA <= 32'bx;
            data_buffer <= 32'bx;
        end else begin
            case (current_state)
                READ_ACT: begin
                    // Decode row and bank address
                    active_row <= HADDR[13:0];
                    active_bank <= HADDR[15:14];
                end

                WRITE_ACT: begin
                    // Decode row and bank address
                    active_row <= HADDR[13:0];
                    active_bank <= HADDR[15:14];
                end

                READ_CAS: begin
                    // Decode column address and read data
                    active_column <= HADDR[24:16];
                    data_buffer <= sdram_memory[active_bank][active_row][active_column];
                end

                WRITE_CAS: begin
                    // Decode column address and buffer data
                    active_column <= HADDR[24:16];
                    data_buffer <= HWDATA;
                end

                READ_NOP2: begin
                    // Update HRDATA with buffered data
                    HRDATA <= data_buffer;
                end

                WRITE_NOP3: begin
                    // Write buffered data to memory
                    sdram_memory[active_bank][active_row][active_column] <= data_buffer;
                end

                default: begin
                    // No operation
                end
            endcase
        end
    end

endmodule
