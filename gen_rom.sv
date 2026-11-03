`resetall
`timescale 1ns / 1ps
`default_nettype none

module gen_rom #
(
    // width of LFSR
    parameter LFSR_WIDTH = 31,
    // LFSR polynomial
    parameter LFSR_POLY = 31'h10000001,
    // LFSR configuration: "GALOIS", "FIBONACCI"
    parameter LFSR_CONFIG = "FIBONACCI",
    // LFSR feed forward enable
    parameter LFSR_FEED_FORWARD = 0,
    // bit-reverse input and output
    parameter REVERSE = 0,
    // width of data input
    parameter DATA_WIDTH = 8,
    // implementation style: "AUTO", "LOOP", "REDUCTION"
    parameter STYLE = "AUTO"
)
(
    input  wire [DATA_WIDTH-1:0] data_in,
    input  wire [LFSR_WIDTH-1:0] state_in,
    output wire [DATA_WIDTH-1:0] data_out,
    output wire [LFSR_WIDTH-1:0] state_out
);



function [LFSR_WIDTH+DATA_WIDTH-1:0] lfsr_mask(input [31:0] index, input [31:0] data_width);
    reg [LFSR_WIDTH-1:0] lfsr_mask_state[LFSR_WIDTH-1:0];
    reg [DATA_WIDTH-1:0] lfsr_mask_data[LFSR_WIDTH-1:0];

    reg [LFSR_WIDTH-1:0] state_val;
    reg [DATA_WIDTH-1:0] data_val;

    reg [DATA_WIDTH-1:0] data_mask;

    integer i, j, m;

    begin
        $display("input parameter index = %x, data_width = %x", index, data_width);
        // init bit masks
        for (i = 0; i < LFSR_WIDTH; i = i + 1) begin
            lfsr_mask_state[i] = 0;
            lfsr_mask_state[i][i] = 1'b1;
            lfsr_mask_data[i] = 0;
        end
                
        // simulate shift register

        // Galois configuration
        for (data_mask = {1'b1, {DATA_WIDTH-1{1'b0}}}, m = 0; /*data_mask != 0*/ m < data_width; data_mask = data_mask >> 1, m = m + 1) begin
            // determine shift in value
            // current value in last FF, XOR with input data bit (MSB first)
            state_val = lfsr_mask_state[LFSR_WIDTH-1];
            data_val = lfsr_mask_data[LFSR_WIDTH-1];
            data_val = data_val ^ data_mask;
            
            // shift
            for (j = LFSR_WIDTH-1; j > 0; j = j - 1) begin
                lfsr_mask_state[j] = lfsr_mask_state[j-1];
                lfsr_mask_data[j] = lfsr_mask_data[j-1];
            end

            if (LFSR_FEED_FORWARD) begin
                // only shift in new input data
                state_val = {LFSR_WIDTH{1'b0}};
                data_val = data_mask;
            end
            lfsr_mask_state[0] = state_val;
            lfsr_mask_data[0] = data_val;

            // add XOR inputs at correct indicies
            for (j = 1; j < LFSR_WIDTH; j = j + 1) begin
                if ((LFSR_POLY >> j) & 1) begin
                    lfsr_mask_state[j] = lfsr_mask_state[j] ^ state_val;
                    lfsr_mask_data[j] = lfsr_mask_data[j] ^ data_val;
                end
            end                             
        end

        // reverse bits if selected
        if (REVERSE) begin
            if (index < LFSR_WIDTH) begin
                state_val = 0;
                for (i = 0; i < LFSR_WIDTH; i = i + 1) begin
                    state_val[i] = lfsr_mask_state[LFSR_WIDTH-index-1][LFSR_WIDTH-i-1];
                end

                data_val = 0;
                //$display("mask_data[%d] = %x", LFSR_WIDTH-index-1, lfsr_mask_data[LFSR_WIDTH-index-1]);
                for (i = 0; i < DATA_WIDTH; i = i + 1) begin
                    data_val[i] = lfsr_mask_data[LFSR_WIDTH-index-1][DATA_WIDTH-i-1];
                end
                //$display("after: data = %x", data_val);
            end else begin
                $display("out of index");
            end
            //$display("state_val = %x, data_val= %x", state_val, data_val);
        end else begin
            if (index < LFSR_WIDTH) begin
                state_val = lfsr_mask_state[index];
                data_val = lfsr_mask_data[index];
            end else begin
                $display("out of index");
            end
        end
        lfsr_mask = {data_val, state_val};
        //lfsr_mask = state_val;
        $display("lfsr_mask[%d] = %x", index, lfsr_mask);
    end
endfunction

function [LFSR_WIDTH+DATA_WIDTH-1:0] lfsr_mask_loop(input [31:0] start);
    reg [LFSR_WIDTH+DATA_WIDTH-1:0] mask_array[128-1:0][32-1:0];
    
    integer m, n;
    integer fd;
    string fname;
    
    begin
        for(m = start; m <= DATA_WIDTH/8; m = m + 1) begin
            for (n = 0; n < LFSR_WIDTH; n = n + 1) begin
                mask_array[m - 1][n] = lfsr_mask(n, m * 8);
            end
        end
        
        //printf
        /*for (n = 0; n < LFSR_WIDTH; n = n + 1) begin
            //for(m = start; m <= DATA_WIDTH/8; m = m + 1) begin
                $display("mask_array[%d][%d] = %x", m, n, mask_array[DATA_WIDTH/8 - 1][n]);
            //end
        end*/
        
        /*for (n = 0; n < LFSR_WIDTH; n = n + 1) begin
            fname = $sformatf("coe_line_%0d.coe",n);
            fd = $fopen(fname, "w");
            if(fd == 0) begin
                $error("cannot open file %s", fname);
            end else begin
                $fwrite(fd, "memory_initialization_radix = 16;\n");
                $fwrite(fd, "memory_initialization_vector = \n");
                for(m = start; m <= DATA_WIDTH/8; m = m + 1) begin
                    $fwrite(fd, "%x", mask_array[m - 1][n]);
                    if(m < DATA_WIDTH/8) begin
                        $fwrite(fd, ",\n");
                    end else begin
                        $fwrite(fd, ";\n");
                    end
                end
                $fclose(fd);                
            end
        end*/
        fname = $sformatf("max_parameter.txt");
        fd = $fopen(fname, "w");
        if(fd == 0) begin
            $error("cannot open file %s", fname);
        end else begin
            for (n = 0; n < LFSR_WIDTH; n = n + 1) begin
                $fwrite(fd, "%x", mask_array[DATA_WIDTH/8 - 1][n][1055:32]);
                if(m < DATA_WIDTH/8) begin
                    $fwrite(fd, ",\n");
                end else begin
                    $fwrite(fd, ";\n");
                end
            end
            $fclose(fd);                
        end
        
        /*fname = $sformatf("state.txt");
        fd = $fopen(fname, "w");
        if(fd == 0) begin
            $error("cannot open file %s", fname);
        end else begin
            for (n = 0; n < LFSR_WIDTH; n = n + 1) begin
                for(m = start; m <= DATA_WIDTH/8; m = m + 1) begin
                    if(m == start) begin
                        $fwrite(fd, "%x", mask_array[m - 1][n][31:0]);
                    end else begin
                        $fwrite(fd, "%x", mask_array[m - 1][n][7:0]);
                    end
                end
                $fclose(fd);                
            end
        end*/
        lfsr_mask_loop = mask_array[m - 1][n - 1];
    end
endfunction

    wire [LFSR_WIDTH+DATA_WIDTH-1:0] mask = lfsr_mask_loop(1);

endmodule

`resetall
