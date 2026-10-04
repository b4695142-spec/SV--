// 知识点：SystemVerilog 定长数组的遍历与逐元素比较
// 1. 数组整体赋值：dst = src，将src整个数组复制给dst
// 2. foreach遍历数组：foreach(dst[i]) 自动遍历所有索引
// 3. 逐元素比较：通过索引逐个访问和比较数组元素
module test;
    bit [31:0] src[5] = '{0,1,2,3,4},
               dst[5] = '{5,4,3,2,1};

    initial begin
        dst = src;
        src[0] = 5;

        foreach(dst[i]) begin
            if (dst[i] == src[i]) $display("src[%0d] == dst[%0d]",i,i);
            else $display("src[%0d] != dst[%0d]",i,i);
        end
    end
endmodule
