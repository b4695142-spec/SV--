// 知识点：有符号数赋值时的符号扩展与 unsigned'() 强制转换
//   byte signed_vector = 8'b1000_0000 = -128
//   直接赋值给 bit[8:0]：符号扩展 → 9'h180 (1_1000_0000)
//   unsigned'() 转换后赋值：零扩展 → 9'h080 (0_1000_0000)
module test (
    byte      signed_vector = 8'b1000_0000,
    bit [8:0] result_vector
);
    initial begin
        result_vector = signed_vector;
        $display("@1 result_vector= 'h%x ",result_vector);
        result_vector = unsigned'(signed_vector);
        $display("@2 result_vector= 'h%x ",result_vector);
    end
endmodule
