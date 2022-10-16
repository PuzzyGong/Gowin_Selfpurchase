`timescale 1ns / 1ps

// `define BACKROUND_R             (6'b110010)
// `define BACKROUND_G             (6'b111000) 
// `define BACKROUND_B             (6'b111010)

`define BACKROUND_R             (6'b000000)
`define BACKROUND_G             (6'b000000) 
`define BACKROUND_B             (6'b000000)

`define CORRODE_COLOR           (16'b00100_001000_00100)
//******************* RST *******************
//-----PARAM_div_color_skin
`define RST_VALUE_0000          (8'h00)
`define RST_VALUE_0001          (8'h00)
`define RST_VALUE_0002          (8'h00)
`define RST_VALUE_0003          (8'h00)
`define RST_VALUE_0004          (8'h00)
`define RST_VALUE_0005          (8'h00)

//-----PARAM_div_color_white
`define RST_VALUE_0006          (8'h15)
`define RST_VALUE_0007          (8'h15)
`define RST_VALUE_0008          (8'h15)
`define RST_VALUE_0009          (8'h10)
`define RST_VALUE_000A          (8'h18)
`define RST_VALUE_000B          (8'hFF)

//-----SWITCH_div_color
`define RST_VALUE_000C          (8'h00)

//-----PARAM_corrode
`define RST_VALUE_000D          (8'h80)

//-----SWITCH_corrode
`define RST_VALUE_000E          (8'h00)

//-----PARAM_div_rect
`define RST_VALUE_000F          (8'h04)

//-----SWITCH_draw
`define RST_VALUE_0010          (8'h01)

//-----PARAM_corv
`define RST_VALUE_0011          (8'h40)
`define RST_VALUE_0012          (8'h08)
`define RST_VALUE_0013          (8'h48)
`define RST_VALUE_0014          (8'h20)
`define RST_VALUE_0015          (8'h48)
`define RST_VALUE_0016          (8'hA0)
`define RST_VALUE_0017          (8'h28)

//-----SWITCH_corv
`define RST_VALUE_0018          (8'h00)

`define RST_VALUE_0019          (8'h00)
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
`define CORROSION_DX            (50)    //即(`PIC_DX / `COR_SIZE)   //要满足: PIC_DX % COR_SIZE = 0
`define CORROSION_DY            (29)    //即(`PIC_DY / `COR_SIZE)   //要满足: PIC_DY % COR_SIZE = 0

`define CORROSION_WIDTH         (7)                                 //要满足: 2 ^ CORROSION_WIDTH >= max(CORROSION_DX, CORROSION_DY)
//降低 CORROSION_SIZE 可能造成 1."show_corroder.v" 中 RAM 容量不足；2.目前未知原因的屏幕黑闪

//******************* RECT_DIVITION *******************
`define RECT_NUMMAX             (16) 
`define RECT_NUMMAX_WIDTH       (4)                                 //要满足: 2 ^ RECT_NUMMAX_WIDTH >= RECT_NUMMAX 

`define RECT_POSSIBILITY_WIDTH  (8)

//******************* LETTER_WRITE *******************
/*unchangeable*/
`define LETTER_PIXEL_SIZE       (4)
`define LETTER_PIXEL_DX         (`OV5640_X / `LETTER_PIXEL_SIZEL)
`define LETTER_PIXEL_DY         (`OV5640_Y / `LETTER_PIXEL_SIZEL)

`define LETTER_PIXEL_WIDTH      8                                   //要满足: 2 ^ LETTER_PIXEL_WIDTH >= max(LETTER_PIXEL_DX, LETTER_PIXEL_DY)
