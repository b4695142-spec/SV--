// 知识点：logic / bit / byte 类型的区别
//   logic — 4值类型(0/1/x/z)，无符号
//   bit   — 2值类型(0/1)，无符号
//   byte  — 2值类型，有符号（等价 bit signed [7:0]）
// 同样初始化为 8'b1000_0000：
//   logic_vector = 128（无符号）
//   bit_vector   = 128（无符号）
//   signed_vector = -128（有符号，最高位为符号位）
module test (
    logic [7:0] logic_vector   = 8'b1000_0000,
    bit   [7:0] bit_vector     = 8'b1000_0000,
    byte        signed_vector  = 8'b1000_0000
);
    initial begin
        $display("logic_vector = %d",  logic_vector);
        $display("bit_vector = %d",    bit_vector);
        $display("signed_vector = %d", signed_vector);
    end
endmodule
