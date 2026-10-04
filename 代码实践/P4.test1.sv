// 知识点：SystemVerilog 结构体(Struct)
// 1. unpacked struct：字段在内存中不连续存储，赋值用 '{值列表}（带撇号）
// 2. packed struct：字段在内存中连续存储，赋值用 {值列表}（不带撇号，即拼接）
// 3. packed struct 可作为整体参与位运算，unpacked struct 不行
// 4. typedef 定义类型后，再用类型名声明变量
module test;
    typedef struct {
        bit [7:0] r;
        bit [7:0] g;
        bit [7:0] b;
    } pixel_s;

    pixel_s my_pixel; // 声明unpacked结构体变量

    typedef struct packed {
        bit [7:0] r;
        bit [7:0] g;
        bit [7:0] b;
    } pixel_p_s;

    pixel_p_s my_pixel_p; // 声明packed结构体变量

    initial begin
        my_pixel   = '{'h10, 'h10, 'h10};   // unpacked结构体赋值，用'{}
        my_pixel_p = {8'h10, 8'h10, 8'h10}; // packed结构体赋值，用{}
    end
endmodule

// 问题1：若去掉"'"，即unpacked结构体赋值从 '{'h10,'h10,'h10} 变成 {'h10,'h10,'h10}，是否还能编译通过？
// 答：不能编译通过。{} 是位拼接运算符，结果为packed类型，不能直接赋给unpacked结构体。
//     unpacked结构体必须用 '{} 赋值。

// 问题2：若packed结构体赋值中不指定位宽，即 {8'h10,8'h10,8'h10} 变成 {'h10,'h10,'h10}，是否会报错？
// 答：不会报错，但结果不正确。'h10 未指定位宽时默认为32位(int)，
//     拼接后总宽度为96位，赋给24位的packed结构体时截取低24位。
//     96位拼接值 = {32'h00000010, 32'h00000010, 32'h00000010}
//     低24位 = 24'h000010
//     因此 r = 8'h00, g = 8'h00, b = 8'h10
