
module kc705_top(
    input         sysclk_p,
    input         sysclk_n,
    input         rst_btn,
    input         mode_btn,
    output [7:0]  led
);

    wire clk;
    IBUFGDS ibufgds_clk (
        .O  (clk),
        .I  (sysclk_p),
        .IB (sysclk_n)
    );


    reg [20:0] rst_dbc;
    reg        rst_db = 1'b0, rst_db_prev = 1'b0;
    reg        rst_pulse;
    always @(posedge clk) begin
        if (rst_btn != rst_db) begin
            rst_dbc <= rst_dbc + 1'b1;
            if (rst_dbc == 21'd1_999_999) begin
                rst_dbc <= 21'd0;
                rst_db  <= rst_btn;
            end
        end else begin
            rst_dbc <= 21'd0;
        end
        rst_db_prev <= rst_db;
        rst_pulse   <= (rst_db != rst_db_prev);   
    end
    wire rst = rst_pulse;


    reg [20:0] db_cnt;
    reg        mode_db = 1'b0;
    always @(posedge clk) begin
        if (rst) begin
            db_cnt  <= 21'd0;
            mode_db <= 1'b0;
        end else if (mode_btn != mode_db) begin
            db_cnt <= db_cnt + 1'b1;
            if (db_cnt == 21'd1_999_999) begin   // 10ms消抖
                db_cnt  <= 21'd0;
                mode_db <= mode_btn;
            end
        end else begin
            db_cnt <= 21'd0;
        end
    end

    reg mode_db_prev = 1'b0;
    reg rearmed      = 1'b1;
    reg mode_sel     = 1'b0;         
    always @(posedge clk) begin
        if (rst) begin
            mode_db_prev <= 1'b0;
            rearmed      <= 1'b1;
            mode_sel     <= 1'b0;
        end else begin
            mode_db_prev <= mode_db;
            if (mode_db_prev == 1'b1 && mode_db == 1'b0 && rearmed) begin
                mode_sel <= ~mode_sel;   
                rearmed  <= 1'b0;
            end
            if (mode_db_prev == 1'b0 && mode_db == 1'b1) begin
                rearmed <= 1'b1;       
            end
        end
    end


    reg [25:0] step_cnt;         
    reg [2:0]  led_idx;           
    always @(posedge clk) begin
        if (rst) begin
            step_cnt <= 26'd0;
            led_idx  <= 3'd0;
        end else if (step_cnt == 26'd39_999_999) begin  
            step_cnt <= 26'd0;
            led_idx  <= led_idx + 1'b1;                 
        end else begin
            step_cnt <= step_cnt + 1'b1;
        end
    end
    wire [7:0] led_run = (8'b0000_0001 << led_idx);      

    
    localparam [1023:0] CRC_DATA = {16{64'h3938373635343332}};  
    wire [1023:0] rom_dout = CRC_DATA;
    wire [127:0]  tkeep = {128{1'b1}};   
    reg  [20:0]   word_div;

    always @(posedge clk) begin
        if (rst)                            word_div <= 21'd0;
        else if (word_div == 21'd1_999_999) word_div <= 21'd0;
        else                                word_div <= word_div + 1'b1;
    end

    wire data_valid = (word_div == 21'd1_999_999);  
    wire data_last  = data_valid;                   

    
    wire [31:0] crc_out;
    combine_crc u_crc (
        .clk        (clk),
        .rst        (rst),
        .data_in    (rom_dout),
        .tkeep      (tkeep),
        .data_last  (data_last),
        .data_valid (data_valid),
        .crc_out    (crc_out)
    );

    assign led = mode_sel ? crc_out[7:0] : led_run;

endmodule
