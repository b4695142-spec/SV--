// 知识点：SystemVerilog 联合体(Union)
// 1. packed union：所有成员共享同一块内存空间，大小等于最大成员的大小
// 2. 联合体中所有成员必须位数相同（packed union要求）
// 3. 写入一个成员后，可通过另一个成员以不同视角解读同一块数据
// 4. 常用于协议字段解析：同一数据既可按RGB解读，也可按YUV解读
// 5. packed struct + packed union 组合可实现高效的位级数据转换
module test;
    typedef struct packed{
    bit [7:0] r;
    bit [7:0] g;
    bit [7:0] b;
    } pixel_rgb_t;

    typedef struct packed{
    bit [15:0] y;
    bit [3:0] u;
    bit [3:0] v;
    } pixel_yuv_t;

    typedef union packed{
    pixel_rgb_t rgb;
    pixel_yuv_t yuv;
    } pixel_t;

    pixel_t pixel_test;
    
    initial begin
        pixel_test = 0;
        $display("Color RGB is: R=%h, G=%h, B=%h",pixel_test.rgb.r, pixel_test.rgb.g,pixel_test.rgb.b);
        
        $display("Color YUV is: Y=%h, U=%h, V=%h",
        pixel_test.yuv.y, pixel_test.yuv.u,pixel_test.yuv.v);
        
        pixel_test.rgb.r=8'hab;
        pixel_test.rgb.g=8'hcd;
        pixel_test.rgb.b=8'hef;
        $display("Color YUV is: Y=%h, U=%h, V=%h",pixel_test.yuv.y, pixel_test.yuv.u,pixel_test.yuv.v);
    end

endmodule

// 问题：联合结构体带来的好处和风险是什么？
// 答：
// 好处：
//   1. 内存共享：多个成员共用同一块存储，节省空间
//   2. 高效数据转换：无需额外转换函数，直接通过不同成员视角解读同一数据，如本例中写入RGB后直接按YUV读取，即可得到对应的位级映射
//   3. 协议解析便捷：网络/总线协议中，同一数据包可按不同字段结构解读
// 风险：
//   1. 类型安全缺失：编译器不跟踪"当前写入的是哪个成员"，程序员可能写入RGB后误读YUV，得到无意义的值
//   2. 可读性降低：代码中难以直观判断当前应以哪个成员视角解读数据
//   3. 调试困难：数据含义取决于上下文，容易引入隐蔽bug
