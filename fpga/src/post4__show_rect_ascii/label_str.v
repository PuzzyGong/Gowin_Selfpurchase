`include "../define.v"

//16 个 长度为 8 的字符串

module label_str
#(
    parameter                           L_W = `LETTER_PIXEL_WIDTH   
)
(
    output             [16 * (8 * 8) - 1 : 0] o_str                       
);

assign o_str = {"        " ,
                "Pie     " ,
                "Pesi    " ,
                "7xi     " ,
                "44444444" ,
                "55555555" ,
                "Tang    " ,
                "Kang    " ,
                "Choc    " ,
                "Coca    " ,
                "AAAAAAAA" ,
                "BBBBBBBB" ,
                "CCCCCCCC" ,
                "DDDDDDDD" ,
                "EEEEEEEE" ,
                "FFFFFFFF"};
                                    
endmodule