// 知识点：4值类型赋值给2值类型时，x/z 被当作 0 处理
//   logic[3:0] = 4'b111x（4值类型，可含x）
//   赋值给 bit[2:0]：x → 0，且高位截断 → 3'b110
module test (
    logic [3:0] x_vector = 4'b111x,
    bit   [2:0] bit_vector
);
    initial begin
        $display("@1 x_vector= 'b%b ",x_vector);
        bit_vector = x_vector;
        $display("@2 bit_vector= 'b%b",bit_vector);
    end
endmodule
