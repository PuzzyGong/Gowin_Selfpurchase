`timescale 1ns / 1ps

// `define BACKROUND_R             (6'b110010)
// `define BACKROUND_G             (6'b111000) 
// `define BACKROUND_B             (6'b111010)
`define BACKROUND_R             (6'b000100)
`define BACKROUND_G             (6'b000100) 
`define BACKROUND_B             (6'b000100)

`define CORRODE_COLOR           (16'b00100_001000_00100)

`define ASCII_RECT_COLOR_GB     (16'b00000_111000_11100) 

`define COLOR_R                 ({8'd255, 8'd000, 8'd000}) 
`define COLOR_G                 ({8'd106, 8'd153, 8'd085}) 
`define COLOR_B                 ({8'd023, 8'd159, 8'd255}) 
`define COLOR_RG                ({8'd255, 8'd215, 8'd000}) 
`define COLOR_RB                ({8'd218, 8'd112, 8'd214}) 
`define COLOR_W                 ({8'd212, 8'd212, 8'd212})  
//******************* RST *******************

//-----div_color_skin____PARAM
`define RST_VALUE_0000          (8'h00)
`define RST_VALUE_0001          (8'h00)
`define RST_VALUE_0002          (8'h00)
`define RST_VALUE_0003          (8'h00)
`define RST_VALUE_0004          (8'h00)
`define RST_VALUE_0005          (8'h00)
//-----div_color_white___PARAM
`define RST_VALUE_0006          (8'h15)
`define RST_VALUE_0007          (8'h15)
`define RST_VALUE_0008          (8'h15)
`define RST_VALUE_0009          (8'h10)
`define RST_VALUE_000A          (8'h18)
`define RST_VALUE_000B          (8'hFF)
//-----div_color________SWITCH
`define RST_VALUE_000C          (8'h00)

//-----corrode___________PARAM
`define RST_VALUE_000D          (8'h80)
//-----corrode__________SWITCH
`define RST_VALUE_000E          (8'h00)

//-----div_rect__________PARAM
`define RST_VALUE_000F          (8'h04)

//-----user
`define RST_VALUE_0010          (8'hFF)

//-----corv1_____________PARAM
`define RST_VALUE_0011          (8'h40)
`define RST_VALUE_0012          (8'h08)
`define RST_VALUE_0013          (8'h58)
`define RST_VALUE_0014          (8'h16)
`define RST_VALUE_0015          (8'h58)
`define RST_VALUE_0016          (8'hA0)
`define RST_VALUE_0017          (8'h18)
//-----corv_____________SWITCH
`define RST_VALUE_0018          (8'h00)

//-----sample___________SWITCH
`define RST_VALUE_0019          (8'h00)

//-----tmp_nouse
`define RST_VALUE_001A          (8'h00)
`define RST_VALUE_001B          (8'h00)
`define RST_VALUE_001C          (8'h00)
`define RST_VALUE_001D          (8'h00)
`define RST_VALUE_001E          (8'h00)
`define RST_VALUE_001F          (8'h00)

//******************* BASE *******************
`define COLOR_WIDTH             (6)
`define ASCII_WIDTH             (7)

//******************* POSITION *******************
/*unchangeable*/
`define OV5640_X                (1024)
`define OV5640_Y                (768)

/*changeable*/
`define PIC_DX                  (800)                               //要满足: PIC_DX为偶数
`define PIC_X1                  (`OV5640_X / 2 - `PIC_DX / 2    )
`define PIC_X2                  (`OV5640_X / 2 + `PIC_DX / 2 - 1)

/*changeable*/
`define PIC_DY                  (464)                               //要满足: PIC_DY为要偶数
`define PIC_Y1                  (0)
`define PIC_Y2                  (`PIC_DY - 1)
`define PIC_Y2_FOR_INTERCEPT    (512-1)

`define POSITION_WIDTH          (10)

//******************* CORROSION *******************
`define CORROSION_SIZE          (16)
//降低 CORROSION_SIZE 可能造成 1."show_corroder.v" 中 RAM 容量不足；2.目前未知原因的屏幕黑闪
`define CORROSION_DX            (50)    //即(`PIC_DX / `COR_SIZE)   //要满足: PIC_DX % COR_SIZE = 0
`define CORROSION_DY            (29)    //即(`PIC_DY / `COR_SIZE)   //要满足: PIC_DY % COR_SIZE = 0

/*unchangeable*/
`define CORROSION_WIDTH         (7)                                 //要满足: 2 ^ CORROSION_WIDTH >= max(CORROSION_DX, CORROSION_DY)
//CORROSION_WIDTH 目前是不可变的，因为程序中有 2^n 的空间划分

//******************* RECT_DIVITION *******************
/*unchangeable*/
`define RECT_NUMMAX             (16) 
`define RECT_NUMMAX_WIDTH       (4)                                 //要满足: 2 ^ RECT_NUMMAX_WIDTH >= RECT_NUMMAX 

//******************* LETTER_WRITE *******************
/*unchangeable*/
`define LETTER_PIXEL_SIZE       (4)
`define LETTER_PIXEL_DX         (`OV5640_X / `LETTER_PIXEL_SIZEL)
`define LETTER_PIXEL_DY         (`OV5640_Y / `LETTER_PIXEL_SIZEL)

`define LETTER_PIXEL_WIDTH      8                                   //要满足: 2 ^ LETTER_PIXEL_WIDTH >= max(LETTER_PIXEL_DX, LETTER_PIXEL_DY)
//LETTER_PIXEL_WIDTH 目前是不可变的，因为程序中有 2^n 的空间划分
