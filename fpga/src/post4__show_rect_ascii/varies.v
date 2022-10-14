`include "../define.v"

//16 个 长度为 4 (总8) 的字符串
//从左向右写，否则会覆盖
module varies
#(
    parameter                           L_W = `LETTER_PIXEL_WIDTH   
)
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    
    input              [128 - 1 : 0]    i_varies                   ,
    output             [16 * (8 * 8) - 1 : 0]  o_str                       
);

reg                    [   3:0]         ones      [0:15]           ;
reg                    [   3:0]         tens      [0:15]           ;
reg                    [   1:0]         hundreds  [0:15]           ;

reg                    [  31:0]         str       [0:15]           ;

integer j;
generate
    genvar i;
    for(i = 0; i < 15; i = i + 1) begin
        always @(*) begin
            ones    [i] = 4'd0;
            tens    [i] = 4'd0;
            hundreds[i] = 2'd0;
            for(j = 7; j >= 0; j = j - 1) begin
                if (ones    [i] >= 4'd5) ones    [i] = ones    [i] + 4'd3;
                if (tens    [i] >= 4'd5) tens    [i] = tens    [i] + 4'd3;
                if (hundreds[i] >= 4'd5) hundreds[i] = hundreds[i] + 4'd3;
                hundreds[i] = {hundreds[i][0]  ,tens    [i][3]    };
                tens    [i] = {tens    [i][2:0],ones    [i][3]    };
                ones    [i] = {ones    [i][2:0],i_varies[i*8+j+:1]};
            end

            str[i][31:24]  =   'd32;
            str[i][23:16]  =  hundreds[i] + 'd48;
            str[i][15: 8]  =  tens    [i] + 'd48;
            str[i][ 7: 0]  =  ones    [i] + 'd48;
        end
    end
endgenerate


assign o_str = {{ 13'b0,      3'b001, 8'd050, 8'd135, str[0]} ,
                { 13'b0,      3'b010, 8'd050, 8'd155, str[1]} ,
                { 13'b0,      3'b100, 8'd050, 8'd175, str[2]} ,
                { 13'b0,      3'b011, 8'd150, 8'd135, str[3]} ,
                { 13'b0,      3'b101, 8'd150, 8'd155, str[4]} ,
                { 13'b0,      3'b110, 8'd150, 8'd175, str[5]} ,
                { 13'b0,      3'b111, 8'd000, 8'd000, "    "} ,
                { 13'b0,      3'b111, 8'd000, 8'd000, "    "} ,
                { 13'b0,      3'b111, 8'd000, 8'd000, "    "} ,
                { 13'b0,      3'b111, 8'd000, 8'd000, "    "} ,
                { 13'b0,      3'b111, 8'd000, 8'd000, "    "} ,
                { 13'b0,      3'b111, 8'd000, 8'd000, "    "} ,
                { 13'b0,      3'b111, 8'd000, 8'd000, "    "} ,
                { 13'b0,      3'b111, 8'd000, 8'd000, "    "} ,
                { 13'b0,      3'b111, 8'd000, 8'd000, "    "} ,
                { 13'b0,      3'b111, 8'd000, 8'd000, "    "}};
                                    
endmodule